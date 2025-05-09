defmodule DashboardWeb.Router do
  use DashboardWeb, :router
  alias DashboardWeb.SpotifyController, as: SpotifyController
  alias DashboardWeb.GoogleController, as: GoogleController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DashboardWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DashboardWeb do
    pipe_through :browser

    live "/", Live.DashboardLive
  end

  scope "/auth" do
    get "/google", GoogleController, :authenticate_user
    get "/google/callback", GoogleController, :callback_user_auth
    post "/auth/google/callback", GoogleController, :callback_user_auth
    get "/spotify", SpotifyController, :authenticate_user
    get "/spotify/callback", SpotifyController, :callback_user_auth
  end

  # Other scopes may use custom stacks.
  scope "/api", DashboardWeb do
    pipe_through :api

    # Need to add weather Icon API
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dashboard, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DashboardWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
