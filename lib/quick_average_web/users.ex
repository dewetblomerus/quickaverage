defmodule QuickAverageWeb.Users do
  def list_users(presence_list) do
    Map.values(presence_list)
    |> Enum.map(fn u ->
      [head | _] = u.metas
      head
    end)
  end
end
