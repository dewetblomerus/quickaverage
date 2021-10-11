use Mix.Config

config :quick_average, QuickAverageWeb.Endpoint,
  url: [host: "av.dev"],
  render_errors: [
    view: QuickAverageWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: QuickAverage.PubSub,
  live_view: [signing_salt: "x0WejuJy"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

if Mix.env() == :dev || Mix.env() == :test do
  import_config "dev_and_test.exs"
end

import_config "#{Mix.env()}.exs"
