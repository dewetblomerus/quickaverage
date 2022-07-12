import Config

if config_env() == :prod do
  config :quick_average,
    username: System.fetch_env!("ADMIN_USERNAME"),
    password: System.fetch_env!("ADMIN_PASSWORD")

  config :quick_average, QuickAverageWeb.Endpoint,
    url: [host: nil, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.fetch_env!("PORT"))
    ],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end
