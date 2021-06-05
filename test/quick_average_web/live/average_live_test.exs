defmodule QuickAverageWeb.AverageLiveTest do
  use QuickAverageWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/some_page_id")
    assert disconnected_html =~ "Waiting for Submissions"
    assert render(page_live) =~ "Waiting for Submissions"
  end
end
