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
        },
        %{
          name: "Shader Correction API",
          path: "/api/shader/correct",
          method: "POST",
          parameters: [
            "shader_code: Original shader code with error",
            "error_message: Compiler error message",
            "original_query: Original description used to generate the shader"
          ]
        }
      ]
    })
  end
end
