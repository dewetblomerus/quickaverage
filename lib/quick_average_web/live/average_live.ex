defmodule QuickAverageWeb.AverageLive do
  require IEx
  use QuickAverageWeb, :live_view
  alias QuickAverageWeb.Presence
  alias QuickAverageWeb.Users

  @impl true
  def mount(%{"room_id" => room_id}, _session, socket) do
    QuickAverageWeb.Endpoint.subscribe(room_id)

    Presence.track(
      self(),
      room_id,
      socket.id,
      %{name: "New User", number: nil}
    )

    {:ok,
     assign(socket,
       name: "",
       number: nil,
       average: nil,
       room_id: room_id,
       users: []
     )}
  end

  @impl true
  def handle_event("update", %{"name" => name, "number" => number}, socket) do
    Presence.update(
      self(),
      socket.assigns.room_id,
      socket.id,
      %{name: name, number: parse_number(number)}
    )

    {:noreply, assign(socket, name: name, number: parse_number(number))}
  end

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} -> Float.round(num, 2)
      _ -> nil
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff"},
        socket
      ) do
    presence_list = Presence.list(socket.assigns.room_id)

    {:noreply,
     assign(socket,
       users: Users.list_users(presence_list),
       average: average(presence_list)
     )}
  end

  defp average(presence_list) do
    numbers =
      Users.list_users(presence_list)
      |> Enum.map(& &1.number)
      |> Enum.filter(&(!is_nil(&1)))

    calculate_average(numbers)
  end

  defp calculate_average([]) do
    nil
  end

  defp calculate_average(numbers) do
    (Enum.sum(numbers) / Enum.count(numbers))
    |> Float.round(2)
  end

  defp display_number(nil) do
    "Waiting"
  end

  defp display_number(number) do
    case Float.ratio(number) do
      {int, 1} -> int
      _ -> number
    end
  end

  defp display_name(text, opts \\ []) do
    max_length = opts[:max_length] || 25
    omission = opts[:omission] || "..."

    cond do
      not String.valid?(text) ->
        text

      String.length(text) < max_length ->
        text

      true ->
        length_with_omission = max_length - String.length(omission)

        "#{String.slice(text, 0, length_with_omission)}#{omission}"
    end
  end
end
