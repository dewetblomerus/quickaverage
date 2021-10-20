defmodule QuickAverageWeb.BenchmarkLive do
  require IEx
  use QuickAverageWeb, :live_view
  alias QuickAverageWeb.Supervisor.Interface, as: SupervisorInterface
  @default_refresh_interval 500

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       room_id: nil,
       number_of_clients: nil,
       refresh_interval: "500"
     )}
  end

  def handle_event(
        "update",
        %{
          "room_id" => room_id,
          "number_of_clients" => input_number_of_clients,
          "refresh_interval" => input_refresh_interval
        },
        socket
      ) do
    supervisor_params = %{
      room_id: room_id,
      number_of_clients: parse_number(input_number_of_clients),
      refresh_interval:
        parse_number(input_refresh_interval, @default_refresh_interval)
    }

    SupervisorInterface.update(supervisor_params)

    {:noreply,
     assign(
       socket,
       room_id: room_id,
       number_of_clients: input_number_of_clients,
       refresh_interval: input_refresh_interval
     )}
  end

  def parse_number(_, default \\ 0)

  def parse_number(nil, default), do: default
  def parse_number("", default), do: default

  def parse_number(input_number, default) when is_binary(input_number) do
    case Integer.parse(input_number) do
      {number, ""} -> number
      _ -> default
    end
  end

  def parse_number(input_number, _) when is_integer(input_number) do
    input_number
  end
end
