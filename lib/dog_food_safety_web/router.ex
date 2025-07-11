defmodule DogFoodSafetyWeb.Router do
  use DogFoodSafetyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DogFoodSafetyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DogFoodSafetyWeb do
    pipe_through :browser

    live "/", SearchLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DogFoodSafetyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:dog_food_safety, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DogFoodSafetyWeb.Telemetry
    end
  end
end