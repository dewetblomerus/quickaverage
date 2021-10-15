use Mix.Config

http_port = 80
https_port = 443

config :quick_average, QuickAverageWeb.Endpoint,
  http: [
    port: http_port,
    transport_options: [socket_opts: [:inet6]]
  ],
  https: [
    port: https_port,
    cipher_suite: :strong,
    transport_options: [socket_opts: [:inet6]]
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  force_ssl: [hsts: true],
  server: true

config :logger, level: :info
