defmodule QuickAverageWeb.HomeLive do
  use QuickAverageWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info(%{setup_user: next_room_id}, socket) do
    {:noreply,
     push_event(socket, "set_storage", %{
       admin_state: "#{next_room_id}:true"
     })}
  end

  defp create_room_link(socket, text, class) do
    next_room_id = System.unique_integer([:positive])
    send(self(), %{setup_user: next_room_id})

    live_redirect(text,
      to:
        Routes.live_path(
          socket,
          QuickAverageWeb.AverageLive,
          next_room_id
        ),
      class: class
    )
  end
end
