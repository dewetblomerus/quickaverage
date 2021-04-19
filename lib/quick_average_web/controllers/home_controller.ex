defmodule QuickAverageWeb.HomeController do
  use QuickAverageWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
