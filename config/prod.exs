import Config

config :quick_average, QuickAverageWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: [hsts: true],
  server: true

config :logger, level: :info
