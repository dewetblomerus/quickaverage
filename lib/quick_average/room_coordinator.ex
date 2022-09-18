defmodule QuickAverage.RoomCoordinator do
  require Logger
  require IEx
  use GenServer
  alias QuickAverage.RoomCoordinator.SupervisorInterface
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState
  @refresh_interval 50
  @idle_seconds_before_stop 10

  def start_link(room_id) when is_binary(room_id) do
    name = {:via, Registry, {QuickAverage.Registry, room_id}}
    GenServer.start_link(__MODULE__, room_id, name: name)
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting RoomCoordinator for #{room_id} 🤖")
    Phoenix.PubSub.subscribe(QuickAverage.PubSub, room_id)

    presence_list = Presence.list(room_id)

    state = %{
      display_version: 0,
      presence_list: presence_list,
      room_id: room_id,
      start_time: now(),
      version: 0
    }

    Process.send_after(self(), {:update, __MODULE__}, 1)

    {:ok, state}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload
        },
        state
      ) do
    :telemetry.execute([:quick_average, :presence_diff], %{
      event: "presence_diff"
    })

    new_presence_list = PresenceState.sync_diff(state.presence_list, payload)

    new_version = state.version + 1

    {:noreply,
     %{state | presence_list: new_presence_list, version: new_version}}
  end

  @impl true
  def handle_info(
        {:update, __MODULE__},
        %{version: version, display_version: display_version} = state
      )
      when version > display_version do
    :telemetry.execute([:quick_average, :update_display], %{
      event: "update_display_data"
    })

    user_list = LiveState.user_list(state.presence_list)

    consider_stopping(user_list, state)

    display_state = %{
      user_list: user_list,
      average: LiveState.average(state.presence_list),
      reveal_by_submission: LiveState.all_submitted?(state.presence_list)
    }

    Presence.pubsub_broadcast(
      "#{state.room_id}-display",
      {:refresh, display_state}
    )

    Process.send_after(self(), {:update, __MODULE__}, @refresh_interval)
    {:noreply, %{state | display_version: version}}
  end

  @impl true
  def handle_info({:update, __MODULE__}, state) do
    Process.send_after(self(), {:update, __MODULE__}, @refresh_interval)
    {:noreply, state}
  end

  def consider_stopping([], state) do
    seconds_alive = now() - state.start_time

    Logger.info(
      "Should we stop #{state.room_id} after seconds_alive: #{seconds_alive} ❓"
    )

    if seconds_alive > @idle_seconds_before_stop do
      Logger.info(
        "Stopping #{state.room_id} after seconds_alive: #{seconds_alive} 🛑"
      )

      SupervisorInterface.delete(self())
    end
  end

  def consider_stopping(_, _), do: nil

  defp now, do: DateTime.now!("Etc/UTC") |> DateTime.to_unix()
end
