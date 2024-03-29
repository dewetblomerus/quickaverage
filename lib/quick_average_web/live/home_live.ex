defmodule QuickAverageWeb.HomeLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    next_room_id = System.unique_integer([:positive])
    {:ok, redirect(socket, to: "/#{next_room_id}")}
  end
end
