defmodule TinycalcWeb.Router do
  use TinycalcWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    # Add CORS support
    plug CORSPlug, origin: "*"
  end

  scope "/api", TinycalcWeb do
    pipe_through :api
    
    post "/shader/generate", ShaderController, :generate
    get "/health", HealthController, :check
  end
  
  # Root path health check
  scope "/", TinycalcWeb do
    pipe_through :api
    
    get "/", HealthController, :check
  end
end