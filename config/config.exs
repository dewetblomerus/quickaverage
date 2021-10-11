use Mix.Config

config :quick_average, QuickAverageWeb.Endpoint,
  url: [host: "av.dev"],
  secret_key_base:
    "HPq5hgfoebR5C8R4ogYNtHj8mJOLZm12nkcZZylVreIEQhHRTuFEPfxcNHi3Bn++",
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

import_config "#{Mix.env()}.exs"
