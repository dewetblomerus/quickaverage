defmodule QuickAverageWeb.Presence do
  @pubsub_server QuickAverage.PubSub

  use Phoenix.Presence,
    otp_app: :quick_average,
    pubsub_server: @pubsub_server

  def pubsub_broadcast(topic, message) do
    Phoenix.PubSub.broadcast(
      @pubsub_server,
      topic,
      message
    )
  end
end
