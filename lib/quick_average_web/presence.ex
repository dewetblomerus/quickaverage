defmodule QuickAverageWeb.Presence do
  use Phoenix.Presence,
    otp_app: :quick_average,
    pubsub_server: QuickAverage.PubSub

  def room_update(socket, meta) do
    update(
      self(),
      socket.assigns.room_id,
      socket.id,
      meta
    )
  end

  def pubsub_broadcast(socket, message) do
    if socket.assigns.admin do
      Phoenix.PubSub.broadcast(
        QuickAverage.PubSub,
        socket.assigns.room_id,
        message
      )
    end
  end
end
