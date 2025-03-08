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
  end
end