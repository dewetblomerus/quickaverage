defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view
  alias Phoenix.PubSub
  alias QuickAverageWeb.AverageLive.State
  alias QuickAverageWeb.Presence

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    QuickAverageWeb.Endpoint.subscribe(room_id)

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{name: "New User", number: nil}
    )

    {:ok,
     assign(socket,
       name: "",
       number: nil,
       average: nil,
       admin: false,
       reveal: false,
       room_id: room_id,
       users: []
     )}
  end

  @impl true
  def handle_event("update", %{"name" => name, "number" => number}, socket) do
    if name != socket.assigns.name do
      send(self(), %{store_name: name})
    end

    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
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
      Presence.update(
        self(),
        socket.assigns.room_id,
        socket.id,
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

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} -> Float.round(num, 2)
      _ -> nil
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff"},
        socket
      ) do
    presence_list = Presence.list(socket.assigns.room_id)
    users = State.list_users(presence_list)

    {:noreply,
     assign(socket,
       users: users,
       average: State.average(presence_list),
       reveal: State.reveal_numbers?(users)
     )}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), "clear_number_front")

    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{name: socket.assigns.name, number: nil}
    )

    presence_list = Presence.list(socket.assigns.room_id)

    {:noreply,
     assign(socket,
       number: nil,
       users: State.list_users(presence_list)
     )}
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
