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
      %{name: name, number: number}
    )

    {:noreply, assign(socket, name: name, nunber: number, average: average(number))}
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
    users = Presence.list(socket.assigns.room_id) |> users_list()

    {:noreply, assign(socket, :users, users)}
  end

  defp average(number) do
    number
  end

  defp users_list(presence_list) do
    Map.values(presence_list)
    |> Enum.map(fn u ->
      [head | _] = u.metas
      head
    end)
  end
end
