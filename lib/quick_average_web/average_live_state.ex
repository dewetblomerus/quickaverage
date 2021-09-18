defmodule QuickAverageWeb.AverageLive.State do
  def average(presence_list) do
    presence_list
    |> user_list()
    |> Enum.filter(&user_counted?/1)
    |> calculate_average()
  end

  def all_submitted?(presence_list) do
    presence_list
    |> user_list()
    |> Enum.reject(&moderator?/1)
    |> Enum.all?(fn user ->
      Map.get(user, :number)
    end)
  end

  def user_list(presence_list) do
    presence_list
    |> Map.values()
    |> Enum.map(&extract_user/1)
  end

  defp user_counted?(user) do
    Map.get(user, :number) != nil && !moderator?(user)
  end

  defp moderator?(user) do
    Map.get(user, :moderator, false)
  end

  defp calculate_average([]) do
    nil
  end

  defp calculate_average(user_list) do
    count = Enum.count(user_list)

    total =
      Enum.reduce(user_list, 0, fn user, acc -> Map.get(user, :number) + acc end)

    (total / count) |> Float.round(2)
  end

  defp extract_user(%{
         metas: [
           %{} = user | _
         ]
       }) do
    user
  end

  def parse_number(nil), do: nil

  def parse_number(number_input) do
    case Float.parse(number_input) do
      {num, ""} ->
        Float.round(num, 2) |> min(1_000_000) |> max(-1_000_000) |> integerize()

      _ ->
        nil
    end
  end

  def integerize(number) when is_integer(number) do
    number
  end

  def integerize(number) when is_float(number) do
    case Float.ratio(number) do
      {int, 1} -> int
      _ -> number
    end
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
