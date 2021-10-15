defmodule QuickAverage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        QuickAverageWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: QuickAverage.PubSub},
        QuickAverageWeb.Presence
        # Start a worker by calling: QuickAverage.Worker.start_link(arg)
        # {QuickAverage.Worker, arg}
      ] ++ endpoint(use_https: Application.get_env(:quick_average, :use_https))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuickAverage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp endpoint(use_https: false) do
    [
      QuickAverageWeb.Endpoint
    ]
  end

  defp endpoint(use_https: true) do
    [
      {SiteEncrypt.Phoenix, QuickAverageWeb.Endpoint}
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    QuickAverageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
