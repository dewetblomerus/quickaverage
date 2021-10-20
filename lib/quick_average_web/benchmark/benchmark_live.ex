defmodule QuickAverageWeb.BenchmarkLive do
  require IEx
  use QuickAverageWeb, :live_view
  alias QuickAverageWeb.Supervisor.Interface, as: SupervisorInterface

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
    number_of_clients = parse_number(input_number_of_clients)
    refresh_interval = parse_number(input_refresh_interval)

    new_assigns = %{
      room_id: room_id,
      number_of_clients: parse_number(number_of_clients),
      refresh_interval: parse_number(refresh_interval)
    }

    SupervisorInterface.update(new_assigns)

    {:noreply,
     assign(
       socket,
       new_assigns
     )}
  end

  def parse_number(nil), do: nil

  def parse_number(input_number) when is_binary(input_number) do
    case Integer.parse(input_number) do
      {number, ""} -> number
      _ -> nil
    end
  end

  def parse_number(input_number) when is_integer(input_number) do
    input_number
  end
end
