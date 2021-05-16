defmodule QuickAverageWeb.HomeLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", number: nil, average: nil, room_id: nil)}
  end

  def handle_event("create-room", _, socket) do
    IO.puts("creating room")
    # socket = assign(socket, :room_id, 100)
    {:noreply,
     push_patch(socket, to: Routes.live_path(socket, QuickAverageWeb.AverageLive, :index))}

    {:noreply, socket}
  end
end
