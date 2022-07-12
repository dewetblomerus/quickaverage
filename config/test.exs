import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quick_average, QuickAverageWeb.Endpoint, server: false

config :logger, level: :warn
