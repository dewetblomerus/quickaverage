defmodule QuickAverageWeb.PageLiveTest do
  use QuickAverageWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/some_page_id")
    assert disconnected_html =~ "Welcome to Quick Average!"
    assert render(page_live) =~ "Welcome to Quick Average!"
  end
end
