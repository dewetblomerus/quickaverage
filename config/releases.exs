import Config

http_port = 80
https_port = 443

config :quick_average,
  username: System.fetch_env!("ADMIN_USERNAME"),
  password: System.fetch_env!("ADMIN_PASSWORD")

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
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  url: [host: System.fetch_env!("HOST"), port: https_port]
