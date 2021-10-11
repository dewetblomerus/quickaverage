defmodule QuickAverageWeb.AverageLive do
  use QuickAverageWeb, :live_view
  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState

  @impl Phoenix.LiveView
  def mount(%{"room_id" => room_id}, _session, socket) do
    QuickAverageWeb.Endpoint.subscribe(room_id)

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{name: "New User", number: nil, only_viewing: false}
    )

    presence_list = Presence.list(room_id)

    is_admin = is_alone?(presence_list)

    if is_admin do
      send(self(), :set_admin)
    end

    {:ok,
     assign(socket,
       admin: is_admin,
       only_viewing: false,
       average: nil,
       name: "",
       number: nil,
       presence_list: presence_list,
       reveal_by_submission: false,
       reveal_by_click: false,
       room_id: room_id,
       debounce: 0
     )}
  end

  @impl true
  def handle_params(_params, url, socket) do
    {:noreply, assign(socket, url: url)}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "update",
        %{
          "name" => input_name,
          "role" => %{"only_viewing" => input_only_viewing}
        } = payload,
        socket
      ) do
    name = LiveState.parse_name(input_name)
    only_viewing = Boolean.parse(input_only_viewing)

    input_number =
      if only_viewing do
        nil
      else
        Map.get(payload, "number")
      end

    if name != socket.assigns.name do
      send(self(), %{store_state: %{name: name}})
    end

    if only_viewing != socket.assigns.only_viewing do
      send(self(), %{store_state: %{only_viewing: only_viewing}})
    end

    number = LiveState.parse_number(input_number)

    new_assigns = %{
      only_viewing: only_viewing,
      name: name,
      number: number
    }

    if LiveState.will_change?(socket.assigns, new_assigns) do
      room_update(
        socket,
        new_assigns
      )
    end

    {:noreply,
     assign(
       socket,
       debounce: debounce(),
       only_viewing: only_viewing,
       name: name,
       number: number
     )}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "restore_user",
        %{
          "admin_state" => admin_state_token,
          "name" => name,
          "only_viewing" => state_only_viewing
        },
        socket
      ) do
    only_viewing = Boolean.parse(state_only_viewing)

    room_update(
      socket,
      %{name: name, number: nil, only_viewing: only_viewing}
    )

    is_admin =
      socket.assigns.admin ||
        is_admin?(socket.assigns.room_id, admin_state_token)

    {:noreply,
     assign(socket, admin: is_admin, name: name, only_viewing: only_viewing)}
  end

  @impl Phoenix.LiveView
  def handle_event(event, _, socket) when event in ["clear", "toggle_reveal"] do
    if socket.assigns.admin do
      Presence.pubsub_broadcast(socket.assigns.room_id, event)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:set_admin, socket) do
    admin_state_token =
      Phoenix.Token.sign(
        QuickAverageWeb.Endpoint,
        "admin state",
        "#{socket.assigns.room_id}:true"
      )

    {:noreply,
     push_event(socket, "set_storage", %{
       admin_state: admin_state_token
     })}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload
        },
        socket
      ) do
    :telemetry.execute([:quick_average, :presence], %{
      event: "presence_diff"
    })

    presence_list =
      PresenceState.sync_diff(socket.assigns.presence_list, payload)

    {:noreply,
     assign(socket,
       average: LiveState.average(presence_list),
       debounce: debounce(),
       presence_list: presence_list,
       reveal_by_submission: LiveState.all_submitted?(presence_list)
     )}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), "clear_number_front")

    room_update(socket, %{number: nil})

    {:noreply, assign(socket, number: nil, reveal_by_click: false)}
  end

  def handle_info(%{store_state: state}, socket) do
    {:noreply, push_event(socket, "set_storage", state)}
  end

  def handle_info("clear_number_front", socket) do
    {:noreply, push_event(socket, "clear_number", %{})}
  end

  def handle_info("toggle_reveal", socket) do
    {:noreply, assign(socket, reveal_by_click: !socket.assigns.reveal_by_click)}
  end

  def debounce do
    {:message_queue_len, queue_length} =
      Process.info(self(), :message_queue_len)

    min(queue_length * 100, 500)
  end

  def is_alone?(presence_list) do
    Enum.count(presence_list) < 2
  end

  def is_admin?(room_id, admin_state_token) do
    admin_string = "#{room_id}:true"

    admin_state =
      Phoenix.Token.verify(
        QuickAverageWeb.Endpoint,
        "admin state",
        admin_state_token,
        max_age: 86_400
      )

    case admin_state do
      {:ok, ^admin_string} -> true
      _ -> false
    end
  end

  def room_update(socket, meta) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      meta
    )
  end

  # template helpers

  defp display_average(_, false), do: "Waiting"

  defp display_average(number, reveal), do: display_number(number, reveal)

  defp display_number(number, reveal, only_viewing \\ false)

  defp display_number(_, _, "true"), do: "SHIT"
  defp display_number(_, _, true), do: "Viewing"

  defp display_number(nil, _, _), do: "Waiting"

  defp display_number(_, false, _), do: "Hidden"

  defp display_number(number, true, _) do
    LiveState.integerize(number)
  end
end
