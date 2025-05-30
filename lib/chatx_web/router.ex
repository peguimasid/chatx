defmodule ChatxWeb.Router do
  use ChatxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatxWeb do
    pipe_through :browser

    # Session management routes
    post "/users/join-chat", UserSessionController, :create
    delete "/users/leave-chat", UserSessionController, :delete

    live_session :assign_user,
      on_mount: [{ChatxWeb.UserSession, :assign_current_user}] do
      live "/", HomeLive.Index
    end

    live_session :require_user,
      on_mount: [{ChatxWeb.UserSession, :require_user}] do
      live "/chat", ChatLive.Index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatxWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chatx, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatxWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
