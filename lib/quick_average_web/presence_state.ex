defmodule QuickAverageWeb.Presence.State do
  def patch(list, %{joins: joins, leaves: leaves}) do
    list
    |> Map.drop(Map.keys(leaves))
    |> Map.merge(joins)
  end
end
