use Mix.Config

config :quick_average,
  username: "asdf",
  password: "asdf"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quick_average, QuickAverageWeb.Endpoint,
  http: [port: 4002],
  server: false,
  secret_key_base:
    "HPq5hgfoebR5C8R4ogYNtHj8mJOLZm12nkcZZylVreIEQhHRTuFEPfxcNHi3Bn++"

# Print only warnings and errors during test
config :logger, level: :warn
