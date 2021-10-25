defmodule QuickAverageWeb.Router do
  use QuickAverageWeb, :router
  import Phoenix.LiveDashboard.Router
  alias QuickAverageWeb.Telemetry

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {QuickAverageWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :admin_basic_auth
  end

  scope "/admin", QuickAverageWeb do
    pipe_through [:browser, :admins_only]
    live_dashboard "/dashboard", metrics: Telemetry
    live "/load-test", LoadTestLive
  end

  defp admin_basic_auth(conn, _opts) do
    username = Application.fetch_env!(:quick_average, :username)
    password = Application.fetch_env!(:quick_average, :password)
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  scope "/", QuickAverageWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/:room_id", AverageLive
  end
end
