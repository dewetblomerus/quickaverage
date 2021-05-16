defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    {:ok, assign(socket, name: "", number: nil, average: nil, room_id: room_id)}
  end

  @impl true
  def handle_event("update", %{"name" => name, "number" => number}, socket) do
    {:noreply, assign(socket, name: name, nunber: number, average: average(number))}
  end

  def handle_event("create-room", _, socket) do
    socket = assign(socket, :room_id, 100)
    {:noreply, socket}
  end

  defp average(number) do
    number
  end
end
