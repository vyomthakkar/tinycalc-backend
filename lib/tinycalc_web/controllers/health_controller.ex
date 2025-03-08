defmodule TinycalcWeb.HealthController do
  use TinycalcWeb, :controller

  def check(conn, _params) do
    json(conn, %{
      status: "ok",
      service: "tinycalc-backend",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      apis: [
        %{
          name: "Shader Generation API",
          path: "/api/shader/generate",
          method: "POST"
        }
      ]
    })
  end
end