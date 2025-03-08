defmodule Tinycalc.LLMService do
  @moduledoc """
  Service for interacting with OpenAI API to generate shader code.
  """
  require Logger

  @doc """
  Generates shader code based on the provided text input using OpenAI API.
  
  ## Examples
      
      iex> Tinycalc.LLMService.generate_shader("Create a simple shader that pulses with red color")
      {:ok, "// Vertex shader\nvoid main() {..."}
      
  """
  @spec generate_shader(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def generate_shader(text_input) do
    api_key = System.get_env("OPENAI_API_KEY")
    
    if is_nil(api_key) or api_key == "" do
      {:error, "OpenAI API key not configured"}
    else
      url = "https://api.openai.com/v1/chat/completions"
      
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ]
      
      prompt = """
      Generate a simple shader program in GLSL based on the following description:
      
      #{text_input}
      
      Provide ONLY the shader code without any explanations or markdown formatting.
      The response should be ready for direct use in a WebGL or other GLSL environment.
      """
      
      body = Jason.encode!(%{
        "model" => "gpt-4o",
        "messages" => [
          %{"role" => "system", "content" => "You are a helpful assistant that generates GLSL shader code."},
          %{"role" => "user", "content" => prompt}
        ],
        "max_tokens" => 2000,
        "temperature" => 0.7
      })
      
      case HTTPoison.post(url, body, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          parsed_response = Jason.decode!(response_body)
          
          # Safely extract content using pattern matching instead of get_in with list index
          content = case parsed_response do
            %{"choices" => [%{"message" => %{"content" => content}} | _]} -> content
            _ -> nil
          end
          
          if is_binary(content) do
            {:ok, String.trim(content)}
          else
            {:error, "Failed to parse shader code from response"}
          end
          
        {:ok, %HTTPoison.Response{status_code: status_code, body: response_body}} ->
          Logger.error("OpenAI API error: #{status_code} - #{response_body}")
          {:error, "OpenAI API error: #{status_code}"}
          
        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("HTTP request error: #{inspect(reason)}")
          {:error, "HTTP request error: #{inspect(reason)}"}
      end
    end
  end
end