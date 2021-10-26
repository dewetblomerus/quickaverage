defmodule QuickAverage.RoomCoordinator.Server do
  require IEx
  use GenServer
  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState

  def start_link(room_id) when is_binary(room_id) do
    name = :"#{room_id}"
    GenServer.start_link(__MODULE__, room_id, name: name)
  end

  @impl true
  def init(room_id) do
    IO.puts("Starting RoomCoordinator for #{room_id} 🔥")
    Phoenix.PubSub.subscribe(QuickAverage.PubSub, room_id)
    # pid_string = inspect(self())

    presence_list = Presence.list(room_id)

    {:ok, %{room_id: room_id, presence_list: presence_list}}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload
        },
        %{room_id: room_id, presence_list: presence_list}
      ) do
    :telemetry.execute([:quick_average, :presence], %{
      event: "presence_diff"
    })

    presence_list = PresenceState.sync_diff(presence_list, payload)

    Presence.pubsub_broadcast(
      "#{room_id}-display",
      {:refresh, %{users_list: presence_list}}
    )

    {:noreply,
     %{
       room_id: room_id,
       average: LiveState.average(presence_list),
       presence_list: presence_list,
       reveal_by_submission: LiveState.all_submitted?(presence_list)
     }}
  end
end
