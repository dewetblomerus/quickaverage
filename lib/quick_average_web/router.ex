defmodule QuickAverageWeb.Router do
  use QuickAverageWeb, :router

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

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: QuickAverageWeb.Telemetry
    end
  end

  scope "/", QuickAverageWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/:room_id", AverageLive
  end
end
