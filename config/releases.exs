import Config

config :quick_average,
  username: System.fetch_env!("ADMIN_USERNAME"),
  password: System.fetch_env!("ADMIN_PASSWORD")

https_port = 443

config :quick_average, QuickAverageWeb.Endpoint,
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
  url: [host: System.fetch_env!("HOST"), port: https_port]
