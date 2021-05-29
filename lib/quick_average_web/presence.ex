defmodule QuickAverageWeb.Presence do
  use Phoenix.Presence,
    otp_app: :quick_average,
    pubsub_server: QuickAverage.PubSub
end
