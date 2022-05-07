defmodule UserListItem do
  use Phoenix.LiveComponent
  alias QuickAverageWeb.AverageLive.State, as: LiveState

  # <.live_component module={UserListItem} id={id} name={name} number={number} />

  def render(assigns) do
    ~H"""
    <tr>
      <td class="text-left max-w-xs pr-2"><%= @name %></td>
      <td class="text-right">
        <%= display_number(
          @number,
          @reveal_by_click || @reveal_by_submission,
          @only_viewing
        ) %>
      </td>
    </tr>
    """
  end

  defp display_number(number, reveal, only_viewing \\ false)

  defp display_number(_, _, "true"), do: "💩"
  defp display_number(_, _, true), do: "Viewing"

  defp display_number(nil, _, _), do: "Waiting"

  defp display_number(_, false, _), do: "Hidden"

  defp display_number(number, true, _) do
    LiveState.integerize(number)
  end
end
