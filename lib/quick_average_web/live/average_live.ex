defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view

  alias QuickAverage.RoomCoordinator.SupervisorInterface,
    as: CoordinatorSupervisor

  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState

  @impl Phoenix.LiveView
  def mount(%{"room_id" => room_id}, _session, socket) do
    send(self(), :initiate_restore_user)

    CoordinatorSupervisor.create(room_id)
    QuickAverageWeb.Endpoint.subscribe(display_topic(room_id))

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{name: "New User", number: nil, only_viewing: false}
    )

    {:ok,
     assign(socket,
       admin: false,
       only_viewing: false,
       average: nil,
       name: "",
       number: nil,
       presence_list: %{},
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
        existing_admin?(socket.assigns.room_id, admin_state_token)

    {:noreply,
     assign(socket, admin: is_admin, name: name, only_viewing: only_viewing)}
  end

  @impl Phoenix.LiveView
  def handle_event("clear", _, socket) do
    if socket.assigns.admin do
      Presence.pubsub_broadcast(display_topic(socket.assigns.room_id), "clear")
    end

    {:noreply, socket}
  end

  def handle_event("toggle_reveal", _, socket) do
    if socket.assigns.admin do
      Presence.pubsub_broadcast(display_topic(socket.assigns.room_id), %{
        set_reveal_by_click: !socket.assigns.reveal_by_click
      })
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

  def handle_info({:refresh, display_state}, socket) do
    is_admin = socket.assigns.admin || is_alone?(display_state.user_list)

    if is_admin != socket.assigns.admin do
      send(self(), :set_admin)
    end

    {:noreply,
     assign(socket,
       admin: is_admin,
       average: display_state.average,
       debounce: debounce(),
       presence_list: display_state.user_list,
       reveal_by_submission: display_state.reveal_by_submission
     )}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), :clear_number)

    room_update(
      socket,
      %{
        only_viewing: socket.assigns.only_viewing,
        name: socket.assigns.name,
        number: nil
      }
    )

    {:noreply, assign(socket, number: nil, reveal_by_click: false)}
  end

  def handle_info(%{store_state: state}, socket) do
    {:noreply, push_event(socket, "set_storage", state)}
  end

  def handle_info(:initiate_restore_user, socket) do
    {:noreply, push_event(socket, "initiate_restore_user", %{})}
  end

  def handle_info(:clear_number, socket) do
    {:noreply, push_event(socket, "clear_number", %{})}
  end

  def handle_info(%{set_reveal_by_click: reveal_by_click}, socket) do
    {:noreply, assign(socket, reveal_by_click: reveal_by_click)}
  end

  defp display_topic(room_id), do: "#{room_id}-display"

  def debounce, do: 0

  def is_alone?([]), do: true
  def is_alone?([_]), do: true
  def is_alone?(_), do: false

  def existing_admin?(room_id, admin_state_token) do
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

  defp display_number(_, _, "true"), do: "💩"
  defp display_number(_, _, true), do: "Viewing"

  defp display_number(nil, _, _), do: "Waiting"

  defp display_number(_, false, _), do: "Hidden"

  defp display_number(number, true, _) do
    LiveState.integerize(number)
  end
end
