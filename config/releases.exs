# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
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

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :quick_average, QuickAverageWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
