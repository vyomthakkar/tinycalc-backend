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

  @doc """
  Correct shader code based on the provided code, error message, and original query
  """
  def correct(conn, %{"shader_code" => shader_code, "error_message" => error_message, "original_query" => original_query})
  when is_binary(shader_code) and is_binary(error_message) and is_binary(original_query) do
    case LLMService.correct_shader(shader_code, error_message, original_query) do
      {:ok, corrected_code} ->
        conn
        |> put_status(:ok)
        |> json(%{
          status: "success",
          shader_code: corrected_code
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

def correct(conn, _params) do
  conn
  |> put_status(:bad_request)
  |> json(%{
    status: "error",
    message: "Missing or invalid parameters. Required: 'shader_code', 'error_message', and 'original_query'"
  })
end

end
