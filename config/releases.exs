import Config

use_https =
  System.get_env("USE_HTTPS", "true")
  |> String.contains?("true")

config :quick_average,
  username: System.fetch_env!("ADMIN_USERNAME"),
  password: System.fetch_env!("ADMIN_PASSWORD"),
  use_https: use_https

port = System.get_env("PORT", "443") |> String.to_integer()

config :quick_average, QuickAverageWeb.Endpoint,
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  url: [host: System.fetch_env!("HOST"), port: port],
  http: [
    port: 80,
    transport_options: [socket_opts: [:inet6]]
  ]

if use_https do
  config :quick_average, QuickAverageWeb.Endpoint,
    https: [
      port: 443,
      cipher_suite: :strong,
      transport_options: [socket_opts: [:inet6]]
    ]
end
