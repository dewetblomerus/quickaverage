defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view
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

    {:noreply, assign(socket, name: name, nunber: parse_number(number))}
  end

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} -> Float.round(num, 2)
      _ -> nil
    end
  end

  def parse_number(_) do
    nil
  end

  def handle_event("create-room", _, socket) do
    socket = assign(socket, :room_id, 100)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: _, leaves: _}},
        %{assigns: %{}} = socket
      ) do
    presence_list = Presence.list(socket.assigns.room_id)

    {:noreply,
     assign(socket,
       users: users_list(presence_list),
       average: average(presence_list)
     )}
  end

  defp average(presence_list) do
    numbers =
      users_list(presence_list)
      |> Enum.map(& &1.number)
      |> Enum.filter(&(!is_nil(&1)))

    calculate_average(numbers)
  end

  defp calculate_average([]) do
    nil
  end

  defp calculate_average(numbers) do
    (Enum.sum(numbers) / Enum.count(numbers)) |> Float.round(2)
  end

  defp users_list(presence_list) do
    Map.values(presence_list)
    |> Enum.map(fn u ->
      [head | _] = u.metas
      head
    end)
  end
end
