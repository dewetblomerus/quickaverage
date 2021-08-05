defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view
  alias Phoenix.PubSub
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState

  @impl true
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
       reveal_reached: false,
       reveal_clicked: false,
       room_id: room_id
     )}
  end

  @impl true
  def handle_event("update", %{"name" => name, "number" => number}, socket) do
    if name != socket.assigns.name do
      send(self(), %{store_name: name})
    end

    presence_update(
      socket,
      %{name: name, number: parse_number(number)}
    )

    {:noreply, assign(socket, name: name, number: parse_number(number))}
  end

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
      presence_update(
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

  def handle_event("clear_clicked", _, socket) do
    if socket.assigns.admin do
      PubSub.broadcast(
        QuickAverage.PubSub,
        socket.assigns.room_id,
        "clear"
      )
    end

    {:noreply, socket}
  end

  def handle_event("reveal", _, socket) do
    if socket.assigns.admin do
      PubSub.broadcast(
        QuickAverage.PubSub,
        socket.assigns.room_id,
        "reveal"
      )
    end

    {:noreply, socket}
  end

  def presence_update(socket, meta) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      meta
    )
  end

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} -> Float.round(num, 2)
      _ -> nil
    end
  end

  def reveal?(presence_list) do
    presence_list
    |> LiveState.list_users()
    |> LiveState.reveal_numbers?()
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload
        },
        socket
      ) do
    presence_list = PresenceState.patch(socket.assigns.presence_list, payload)

    {:noreply,
     assign(socket,
       average: LiveState.average(presence_list),
       presence_list: presence_list,
       reveal_reached: reveal?(presence_list) || socket.assigns.reveal_clicked
     )}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), "clear_number_front")

    presence_update(
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
    {:noreply, assign(socket, reveal_clicked: true, reveal_reached: true)}
  end

  # template helpers

  defp display_average(_, false), do: "Waiting"

  defp display_average(number, reveal), do: display_number(number, reveal)

  defp display_number(nil, _), do: "Waiting"

  defp display_number(_, false), do: "Hidden"

  defp display_number(number, true) do
    case Float.ratio(number) do
      {int, 1} -> int
      _ -> number
    end
  end

  defp display_name(text, opts \\ []) do
    max_length = opts[:max_length] || 25
    omission = opts[:omission] || "..."

    cond do
      not String.valid?(text) ->
        text

      String.length(text) < max_length ->
        text

      true ->
        length_with_omission = max_length - String.length(omission)

        "#{String.slice(text, 0, length_with_omission)}#{omission}"
    end
  end
end
