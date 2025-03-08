defmodule TinycalcWeb.Router do
  use TinycalcWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TinycalcWeb do
    pipe_through :api
  end
end
