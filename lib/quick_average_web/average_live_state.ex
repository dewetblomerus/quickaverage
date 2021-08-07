defmodule QuickAverageWeb.AverageLive.State do
  def average(presence_list) do
    presence_list |> Map.values() |> average(0, 0)
  end

  defp average([], 0, 0), do: nil

  defp average([], total, length) do
    (total / length) |> Float.round(2)
  end

  defp average([%{metas: [%{number: number}]} | tail], total, length)
       when not is_nil(number) do
    average(tail, total + number, length + 1)
  end

  defp average([_ | tail], total, length) do
    average(tail, total, length)
  end

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} ->
        Float.round(num, 2) |> clip_num() |> integerize()

      _ ->
        nil
    end
  end

  def clip_num(number) do
    case number do
      num when num > 1_000_000 -> 1_000_000
      num when num < -1_000_000 -> -1_000_000
      _ -> number
    end
  end

  def integerize(number) when is_integer(number) do
    number
  end

  def integerize(number) do
    case Float.ratio(number) do
      {int, 1} -> int
      _ -> number
    end
  end

  def all_submitted?(presence_list) do
    Enum.all?(presence_list, fn presence ->
      {_, %{metas: [%{number: number}]}} = presence
      number
    end)
  end

  def parse_name(name) do
    max_length = 25
    omission = "..."

    cond do
      not String.valid?(name) ->
        "Bob"

      String.length(name) < max_length ->
        name

      true ->
        length_with_omission = max_length - String.length(omission)

        "#{String.slice(name, 0, length_with_omission)}#{omission}"
    end
  end

  def will_change?(current, changes) do
    subset = Map.take(current, Map.keys(changes))
    !Map.equal?(subset, changes)
  end
end
