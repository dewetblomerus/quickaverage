defmodule QuickAverageWeb.PageLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", number: nil, average: nil)}
  end

  @impl true
  def handle_event("update", %{"name" => name, "number" => number}, socket) do
    {:noreply, assign(socket, name: name, nunber: number, average: average(number))}
  end

  defp average(number) do
    number
  end
end
