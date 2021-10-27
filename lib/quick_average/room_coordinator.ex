defmodule QuickAverage.RoomCoordinator do
  require Logger
  require IEx
  use GenServer
  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState
  @refresh_interval 50

  def start_link(room_id) when is_binary(room_id) do
    name = :"#{__MODULE__}-#{room_id}"
    GenServer.start_link(__MODULE__, room_id, name: name)
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting RoomCoordinator for #{room_id} 🤖")
    Phoenix.PubSub.subscribe(QuickAverage.PubSub, room_id)
    # pid_string = inspect(self())

    presence_list = Presence.list(room_id)
    state = %{room_id: room_id, presence_list: presence_list}
    Process.send_after(self(), {:update, __MODULE__}, 1)

    {:ok, state}
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

    {:noreply,
     %{
       room_id: room_id,
       presence_list: presence_list
     }}
  end

  def handle_info({:update, __MODULE__}, state) do
    display_state = %{
      user_list: LiveState.user_list(state.presence_list),
      average: LiveState.average(state.presence_list),
      reveal_by_submission: LiveState.all_submitted?(state.presence_list)
    }

    Presence.pubsub_broadcast(
      "#{state.room_id}-display",
      {:refresh, display_state}
    )

    Process.send_after(self(), {:update, __MODULE__}, @refresh_interval)
    {:noreply, state}
  end
end
