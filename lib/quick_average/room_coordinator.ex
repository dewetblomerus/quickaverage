defmodule QuickAverage.RoomCoordinator do
  require Logger
  require IEx
  use GenServer
  alias QuickAverage.RoomCoordinator.SupervisorInterface
  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Presence.State, as: PresenceState
  @refresh_interval 50
  @idle_seconds_before_stop 10

  def start_link(room_id) when is_binary(room_id) do
    name = :"#{__MODULE__}-#{room_id}"
    GenServer.start_link(__MODULE__, room_id, name: name)
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting RoomCoordinator for #{room_id} 🤖")
    Phoenix.PubSub.subscribe(QuickAverage.PubSub, room_id)

    presence_list = Presence.list(room_id)

    state = %{
      room_id: room_id,
      presence_list: presence_list,
      start_time: now()
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
    :telemetry.execute([:quick_average, :presence], %{
      event: "presence_diff"
    })

    new_presence_list = PresenceState.sync_diff(state.presence_list, payload)

    {:noreply, %{state | presence_list: new_presence_list}}
  end

  def handle_info({:update, __MODULE__}, state) do
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

  defp now(), do: DateTime.now!("Etc/UTC") |> DateTime.to_unix()
end
