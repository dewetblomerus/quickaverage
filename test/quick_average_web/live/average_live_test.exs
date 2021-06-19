defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the home page", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome"
    assert render(page_live) =~ "Welcome"
  end

  test "renders a room page", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/some_page_id")
    assert disconnected_html =~ "Waiting"
    assert render(page_live) =~ "Waiting"
  end
end
