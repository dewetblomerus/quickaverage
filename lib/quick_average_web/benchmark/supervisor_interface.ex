defmodule QuickAverageWeb.Supervisor.Interface do
  require Logger
  alias QuickAverageWeb.Benchmark.User

  @supervisor QuickAverageWeb.BenchmarkSupervisor

  def update(
        %{
          room_id: room_id,
          number_of_clients: input_number,
          refresh_interval: refresh_interval
        } = params
      ) do
    desired_number = parse_number(input_number)
    children_number_diff = desired_number - Enum.count(children())

    adjust(params, children_number_diff)
  end

  def parse_number(nil), do: 0
  def parse_number(""), do: 0
  def parse_number(input_number), do: input_number

  def adjust(
        %{
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        } = params,
        diff
      )
      when diff > 0 do
    Logger.info(diff, label: "diff")
    1..diff |> Enum.each(fn _ -> create(room_id, refresh_interval) end)
  end

  def adjust(
        %{
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        } = params,
        diff
      )
      when diff < 0 do
    Logger.info(diff, label: "diff")
    -1..diff |> Enum.each(fn _ -> delete() end)
  end

  def adjust(_, 0) do
    Logger.info("desired number reached")
  end

  def create(room_id, refresh_interval) do
    DynamicSupervisor.start_child(
      @supervisor,
      {User, {room_id, refresh_interval}}
    )
  end

  def children do
    DynamicSupervisor.which_children(@supervisor)
  end

  def delete do
    # IEx.pry()
    [{_, pid, _, _} | _] = DynamicSupervisor.which_children(@supervisor)
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end
end
