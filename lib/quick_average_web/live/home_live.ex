defmodule QuickAverageWeb.HomeLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp create_room_link(socket, text, class) do
    live_redirect(text,
      to:
        Routes.live_path(
          socket,
          QuickAverageWeb.AverageLive,
          System.unique_integer([:positive])
        ),
      class: class
    )
  end
end
