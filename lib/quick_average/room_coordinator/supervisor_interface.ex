defmodule QuickAverage.RoomCoordinator.SupervisorInterface do
  require Logger

  @genserver QuickAverage.RoomCoordinator
  @supervisor QuickAverage.RoomCoordinatorSupervisor

  def create(room_id) do
    DynamicSupervisor.start_child(
      @supervisor,
      {@genserver, room_id}
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
