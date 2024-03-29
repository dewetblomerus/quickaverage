defmodule QuickAverageWeb.LoadTest.User do
  use GenServer
  import QuickAverageWeb.AverageLive
  alias QuickAverage.Boolean
  alias QuickAverageWeb.AverageLive.State, as: LiveState
  alias QuickAverageWeb.Presence
  require IEx

  def start_link({room_id, refresh_interval}) when is_binary(room_id) do
    GenServer.start_link(__MODULE__, {room_id, refresh_interval})
  end

  @impl true
  def init({room_id, refresh_interval}) do
    QuickAverageWeb.Endpoint.subscribe(display_topic(room_id))
    pid_string = inspect(self())
    socket = %{id: pid_string}

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{name: "LoadTest User", number: nil, only_viewing: false}
    )

    presence_list = Presence.list(room_id)

    is_admin = is_alone?(presence_list)

    if is_admin do
      send(self(), :set_admin)
    end

    assigns = %{
      admin: false,
      only_viewing: false,
      average: nil,
      name: "LoadTest User",
      number: nil,
      presence_list: presence_list,
      reveal_by_submission: false,
      reveal_by_click: false,
      room_id: room_id,
      debounce: 0
    }

    :timer.send_interval(refresh_interval, :tick)
    {:ok, %{assigns: assigns, id: pid_string}}
  end

  def handle_event("toggle_reveal", _, socket) do
    if socket.assigns.admin do
      Presence.pubsub_broadcast(socket.assigns.room_id, %{
        set_reveal_by_click: !socket.assigns.reveal_by_click
      })
    end

    {:noreply, socket}
  end

  def push_event(_, _, _), do: :ok

  @impl true
  def handle_info(
        :tick,
        socket
      ) do
    input_name =
      [
        "Darth Vader",
        "Luke Skywalker",
        "Princess Leia",
        "Yoda",
        "Emperor Palpatine",
        "Obi-Wan Kenobi",
        "Han Solo",
        "Chewbacca"
      ]
      |> Enum.random()

    input_only_viewing = false
    input_number = Enum.random(-1_000_000..1_000_000) |> Integer.to_string()
    name = LiveState.parse_name(input_name)
    only_viewing = Boolean.parse(input_only_viewing)

    input_number =
      if only_viewing do
        nil
      else
        input_number
      end

    if name != socket.assigns.name do
      send(self(), %{store_state: %{name: name}})
    end

    if only_viewing != socket.assigns.only_viewing do
      send(self(), %{store_state: %{only_viewing: only_viewing}})
    end

    number = LiveState.parse_number(input_number)

    new_assigns = %{
      only_viewing: only_viewing,
      name: name,
      number: number
    }

    if LiveState.will_change?(socket.assigns, new_assigns) do
      room_update(
        socket,
        new_assigns
      )
    end

    {:noreply,
     assign(
       socket,
       debounce: debounce(),
       only_viewing: only_viewing,
       name: name,
       number: number
     )}
  end

  @impl true
  def handle_info({:refresh, display_state}, socket) do
    {:noreply,
     assign(socket,
       average: display_state.average,
       debounce: debounce(),
       presence_list: display_state.user_list,
       reveal_by_submission: display_state.reveal_by_submission
     )}
  end

  @impl true
  def handle_info(:set_admin, socket) do
    admin_state_token =
      Phoenix.Token.sign(
        QuickAverageWeb.Endpoint,
        "admin state",
        "#{socket.assigns.room_id}:true"
      )

    {:noreply,
     push_event(socket, "set_storage", %{
       admin_state: admin_state_token
     })}
  end

  @impl true
  def handle_info("clear", socket) do
    send(self(), :clear_number)

    room_update(
      socket,
      %{
        only_viewing: socket.assigns.only_viewing,
        name: socket.assigns.name,
        number: nil
      }
    )

    {:noreply, assign(socket, number: nil, reveal_by_click: false)}
  end

  @impl true
  def handle_info(%{store_state: _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_number, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{set_reveal_by_click: reveal_by_click}, socket) do
    {:noreply, assign(socket, reveal_by_click: reveal_by_click)}
  end

  def assign(_, _, opts \\ [])

  def assign(:ok, %{assigns: assigns} = socket, opts) do
    new_assigns = Enum.into(opts, assigns)
    Map.replace!(socket, :assigns, new_assigns)
  end

  def assign(%{assigns: assigns} = socket, _assings_kwlist, opts) do
    new_assigns = Enum.into(opts, assigns)
    Map.replace!(socket, :assigns, new_assigns)
  end

  defp display_topic(room_id), do: "#{room_id}-display"
end
