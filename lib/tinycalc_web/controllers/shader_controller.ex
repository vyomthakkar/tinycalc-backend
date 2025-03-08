defmodule TinycalcWeb.ShaderController do
  use TinycalcWeb, :controller
  
  alias Tinycalc.LLMService
  
  @doc """
  Generate shader code based on the provided text input
  """
  def generate(conn, %{"input" => input}) when is_binary(input) do
    case LLMService.generate_shader(input) do
      {:ok, shader_code} ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "success",
          shader_code: shader_code
        })
        
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end
  
  def generate(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      status: "error",
      message: "Missing or invalid 'input' parameter"
    })
  end
end