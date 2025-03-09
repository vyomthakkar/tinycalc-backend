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
Generate a GLSL shader based on this description: "#{text_input}"

IMPORTANT CONSTRAINTS:
1. DO NOT use any matrix uniforms or 3D transformations
2. Use ONLY these uniforms: u_time, u_resolution, and u_mouse
3. Keep the vertex shader simple with gl_Position = a_position;
4. Create all visual effects in the fragment shader only
5. NO markdown formatting or code blocks

Your response must follow this exact structure:

// Vertex Shader
#version 300 es
precision mediump float;

in vec4 a_position;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  gl_Position = a_position;  // DO NOT CHANGE THIS LINE
}

// Fragment Shader
#version 300 es
precision mediump float;

out vec4 outColor;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(0.0);

  // Implement the effect: "#{text_input}" here

  outColor = vec4(color, 1.0);
}
"""

      body = Jason.encode!(%{
        "model" => "gpt-4o",
        "messages" => [
          %{"role" => "system", "content" => "You are a helpful assistant that generates GLSL shader code."},
          %{"role" => "user", "content" => prompt}
        ],
        "max_tokens" => 2000,
        "temperature" => 0.2
      })

      # open ai api timeout is set to 2 minutes (120000 ms)
      case HTTPoison.post(url, body, headers, [timeout: 120000, recv_timeout: 120000]) do
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

 @doc """
  Corrects shader code based on the provided code, error message, and original query.

  ## Examples

      iex> Tinycalc.LLMService.correct_shader("void main() {...", "ERROR: 'foo' : undeclared identifier", "Create a red pulsating shader")
      {:ok, "// Corrected shader\nvoid main() {..."}

  """
  @spec correct_shader(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def correct_shader(shader_code, error_message, original_query) do
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
      I have a GLSL shader with the following error:

      ORIGINAL QUERY:
      #{original_query}

      ERROR MESSAGE:
      #{error_message}

      ORIGINAL SHADER CODE:
      #{shader_code}

      IMPORTANT CONSTRAINTS:
      1. DO NOT use any matrix uniforms or 3D transformations
      2. Use ONLY these uniforms: u_time, u_resolution, and u_mouse
      3. Keep the vertex shader simple with gl_Position = a_position;
      4. Create all visual effects in the fragment shader only
      5. NO markdown formatting or code blocks

      Your response must follow this exact structure:

      // Vertex Shader
      #version 300 es
      precision mediump float;

      in vec4 a_position;
      uniform float u_time;
      uniform vec2 u_resolution;

      void main() {
        gl_Position = a_position;  // DO NOT CHANGE THIS LINE
      }

      // Fragment Shader
      #version 300 es
      precision mediump float;

      out vec4 outColor;
      uniform float u_time;
      uniform vec2 u_resolution;

      void main() {
        vec2 st = gl_FragCoord.xy / u_resolution;
        vec3 color = vec3(0.0);

        // Implement the effect: "#{original_query}" here

        outColor = vec4(color, 1.0);
      }
      """

      body = Jason.encode!(%{
        "model" => "gpt-4o",
        "messages" => [
          %{"role" => "system", "content" => "You are a helpful assistant that corrects GLSL shader code."},
          %{"role" => "user", "content" => prompt}
        ],
        "max_tokens" => 2000,
        "temperature" => 0.2
      })

      # Use same timeout as generate_shader (2 minutes)
      case HTTPoison.post(url, body, headers, [timeout: 120000, recv_timeout: 120000]) do
        {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
          parsed_response = Jason.decode!(response_body)

          # Safely extract content using pattern matching
          content = case parsed_response do
            %{"choices" => [%{"message" => %{"content" => content}} | _]} -> content
            _ -> nil
          end

          if is_binary(content) do
            {:ok, String.trim(content)}
          else
            {:error, "Failed to parse corrected shader code from response"}
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
