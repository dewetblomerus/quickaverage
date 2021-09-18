use Mix.Config

config :quick_average,
  username: "asdf",
  password: "asdf"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quick_average, QuickAverageWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
