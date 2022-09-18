defmodule QuickAverage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      QuickAverageWeb.Telemetry,
      {Phoenix.PubSub, name: QuickAverage.PubSub},
      QuickAverageWeb.Presence,
      {Registry, keys: :unique, name: QuickAverage.Registry},
      {DynamicSupervisor,
       strategy: :one_for_one, name: QuickAverageWeb.LoadTestSupervisor},
      {DynamicSupervisor,
       strategy: :one_for_one, name: QuickAverage.RoomCoordinatorSupervisor},
      QuickAverageWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: QuickAverage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    QuickAverageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
