defmodule QuickAverageWeb.Supervisor.Interface do
  require IEx
  @supervisor QuickAverageWeb.BenchmarkSupervisor
  alias QuickAverageWeb.Benchmark.User

  def update(
        room_id: _room_id,
        number_of_clients: nil,
        refresh_interval: _refresh_interval
      ),
      do: :ok

  def update(
        [
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        ] = params
      ) do
    current_number = Enum.count(children())
    adjust(params, current_number)
  end

  def adjust(
        [
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        ] = params,
        current_number
      )
      when current_number < desired_number do
    IO.inspect(current_number, label: "current_number")
    IO.inspect(desired_number, label: "desired_number")
    create(room_id, refresh_interval)
    adjust(params, Enum.count(children))
  end

  def adjust(
        [
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        ] = params,
        current_number
      )
      when current_number > desired_number do
    IO.inspect(current_number, label: "current_number")
    IO.inspect(desired_number, label: "desired_number")
    delete()
    adjust(params, Enum.count(children))
  end

  def adjust(
        [
          room_id: room_id,
          number_of_clients: desired_number,
          refresh_interval: refresh_interval
        ],
        current_number
      ) do
    IO.inspect(current_number, label: "current_number")
    IO.inspect(desired_number, label: "desired_number")
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
