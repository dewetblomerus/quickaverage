defmodule QuickAverageWeb.Presence.State do
  def sync_diff(list, %{joins: joins, leaves: leaves}) do
    list
    |> Map.drop(Map.keys(leaves))
    |> Map.merge(joins)
  end
end
