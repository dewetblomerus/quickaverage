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
        %{"admin_state" => admin_state},
        socket
      ) do
    admin_string = "#{socket.assigns.room_id}:true"

    admin =
      case admin_state do
        ^admin_string -> true
        _ -> false
      end

    {:noreply, assign(socket, admin: admin)}
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
