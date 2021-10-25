defmodule QuickAverageWeb.Supervisor.Interface do
  require Logger
  alias QuickAverageWeb.LoadTest.User

  @supervisor QuickAverageWeb.LoadTestSupervisor

  def update(%{number_of_clients: desired_number} = params) do
    children_number_diff = desired_number - Enum.count(children())

    adjust(params, children_number_diff)
  end

  def adjust(
        %{
          room_id: room_id,
          refresh_interval: refresh_interval
        },
        diff
      )
      when diff > 0 do
    Logger.info(Integer.to_string(diff), label: "diff")
    1..diff |> Enum.each(fn _ -> create(room_id, refresh_interval) end)
  end

  def adjust(_, diff) when diff < 0 do
    Logger.info(Integer.to_string(diff), label: "diff")
    -1..diff |> Enum.each(fn _ -> delete() end)
  end

  def adjust(_, 0) do
    Logger.info("desired number reached")
  end

  def create(room_id, refresh_interval) when is_integer(refresh_interval) do
    DynamicSupervisor.start_child(
      @supervisor,
      {User, {room_id, refresh_interval}}
    )
  end

  def children do
    DynamicSupervisor.which_children(@supervisor)
  end

  def delete do
    [{_, pid, _, _} | _] = DynamicSupervisor.which_children(@supervisor)
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end
end
