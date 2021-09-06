defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view
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
      %{name: "New User", number: nil}
    )

    presence_list = Presence.list(room_id)

    {:ok,
     assign(socket,
       admin: false,
       average: nil,
       name: "",
       number: nil,
       presence_list: presence_list,
       reveal: false,
       reveal_clicked: false,
       room_id: room_id
     )}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "update",
        %{"name" => input_name, "number" => input_number},
        socket
      ) do
    name = LiveState.parse_name(input_name)

    if name != socket.assigns.name do
      send(self(), %{store_name: name})
    end

    number = LiveState.parse_number(input_number)

    new_assigns = %{name: name, number: number}

    if LiveState.will_change?(socket.assigns, new_assigns) do
      Presence.room_update(
        socket,
        new_assigns
      )
    end

    {:noreply, assign(socket, name: name, number: number)}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "restore_user",
        %{"admin_state" => admin_state_token, "name" => name},
        socket
      ) do
    admin_string = "#{socket.assigns.room_id}:true"

    admin_state =
      Phoenix.Token.verify(
        QuickAverageWeb.Endpoint,
        "admin state",
        admin_state_token,
        max_age: 86_400
      )

    if name do
      Presence.room_update(
        socket,
        %{name: name, number: nil}
      )
    end

    admin =
      case admin_state do
        {:ok, ^admin_string} -> true
        _ -> false
      end

    {:noreply, assign(socket, admin: admin, name: name)}
  end

  @impl Phoenix.LiveView
  def handle_event("clear_clicked", _, socket) do
    Presence.pubsub_broadcast(socket, "clear")
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("reveal", _, socket) do
    Presence.pubsub_broadcast(socket, "reveal")
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload
        },
        socket
      ) do
    presence_list =
      PresenceState.sync_diff(socket.assigns.presence_list, payload)

    reveal =
      socket.assigns.reveal_clicked ||
        LiveState.all_submitted?(presence_list)

    {:noreply,
     assign(socket,
       average: LiveState.average(presence_list),
       presence_list: presence_list,
       reveal: reveal
     )}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), "clear_number_front")

    Presence.room_update(
      socket,
      %{name: socket.assigns.name, number: nil}
    )

    {:noreply, assign(socket, number: nil, reveal_clicked: false)}
  end

  def handle_info(%{store_name: name}, socket) do
    {:noreply,
     push_event(socket, "set_storage", %{
       name: name
     })}
  end

  def handle_info("clear_number_front", socket) do
    {:noreply, push_event(socket, "clear_number", %{})}
  end

  def handle_info("reveal", socket) do
    {:noreply, assign(socket, reveal_clicked: true, reveal: true)}
  end

  # template helpers

  defp display_average(_, false), do: "Waiting"

  defp display_average(number, reveal), do: display_number(number, reveal)

  defp display_number(nil, _), do: "Waiting"

  defp display_number(_, false), do: "Hidden"

  defp display_number(number, true), do: LiveState.integerize(number)
end
