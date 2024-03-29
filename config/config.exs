import Config

config :quick_average,
  use_https: true

config :quick_average, QuickAverageWeb.Endpoint,
  render_errors: [
    view: QuickAverageWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: QuickAverage.PubSub,
  live_view: [signing_salt: "x0WejuJy"]

config :esbuild,
  version: "0.13.4",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

if Mix.env() == :dev || Mix.env() == :test do
  import_config "dev_and_test.exs"
end

config :tailwind,
  version: "3.0.24",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{Mix.env()}.exs"
