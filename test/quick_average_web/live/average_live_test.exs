defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase

  import Phoenix.LiveViewTest

  test "redirected mount", %{conn: conn} do
    assert {:error, {:redirect, %{to: _}}} = live(conn, "/")
  end

  test "renders a room page", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/some_room_id")
    assert disconnected_html =~ "Waiting"
    assert render(page_live) =~ "Waiting"
  end
end
