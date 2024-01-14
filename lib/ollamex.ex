# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex do
  @moduledoc """
  Ollamex is an Elixir wrapper of [ollama](https://ollama.ai/)'s REST API. This is the main module that contains high-level functions that the user will typically interact with.

  Ollamex is written based on the [ollama REST API documentation](https://github.com/jmorganca/ollama/blob/main/docs/api.md) for the following endpoints:

  * [List Local Models](https://github.com/jmorganca/ollama/blob/main/docs/api.md#list-local-models)
  * [Generate a completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion)
  * [Generate a chat completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion)
  * [Generate embeddings](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-embeddings)

  Tested with ollama version 0.1.20.

  ## Examples

  ### API initialization

  ```elixir
  iex> api = Ollamex.API.new()
  %Ollamex.API{
    uri: "http://localhost:11434/api",
    models: [
      %Ollamex.LLModel{
        name: "llama2:latest",
        digest: "78e26419b4469263f75331927a00a0284ef6544c1975b826b15abdaef17bb962",
        modified_at: "2024-01-09T22:24:14.925918123+02:00",
        size: 3826793677,
        details: %{
          "families" => ["llama"],
          "family" => "llama",
          "format" => "gguf",
          "parameter_size" => "7B",
          "quantization_level" => "Q4_0"
        },
        modelfile: nil,
        parameters: nil,
        template: nil
      },
      %Ollamex.LLModel{
        name: "mistral:latest",
        digest: "61e88e884507ba5e06c49b40e6226884b2a16e872382c2b44a42f2d119d804a5",
        modified_at: "2024-01-08T17:49:54.570542101+02:00",
        size: 4109865159,
        details: %{
          "families" => ["llama"],
          "family" => "llama",
          "format" => "gguf",
          "parameter_size" => "7B",
          "quantization_level" => "Q4_0"
        },
        modelfile: nil,
        parameters: nil,
        template: nil
      }
    ],
    timeout: 120000,
    errors: []
    }
    iex> Ollamex.API.list_models(api)
    ["llama2:latest", "mistral:latest"]
  ```

  ### Generate a completion (`/generate` endpoint)

  ```elixir
  iex> p = %Ollamex.PromptRequest{model: "mistral:latest", prompt: "Explain using a simple paragraph like I'm 5 years old: Why is the sky not black like space?"}
  %Ollamex.PromptRequest{
    model: "mistral:latest",
    prompt: "Explain using a simple paragraph like I'm 5 years old: Why is the sky not black like space?",
    raw: false,
    format: nil,
    stream: true,
    options: nil,
    images: []
  }

  iex> Ollamex.generate_with_timeout(p, api)
  {:ok,
    %Ollamex.LLMResponse{
    context: [733, 16289, 28793, ...],
    created_at: "2024-01-10T19:23:12.943599755Z",
    done: true,
    eval_count: 100,
    eval_duration: 16850322000,
    model: "mistral:latest",
    prompt_eval_count: 33,
    prompt_eval_duration: 2865358000,
    response: " The sky isn't black like space because it has [...]
    pretty colors, and nighttime with stars and the moon!",
    total_duration: 24862993618,
    message: nil,
    errors: nil
  }}
  ```

  ### Generate a chat completion (`/chat` endpoint)

  ```elixir
  messages =
    []
    |> Ollamex.ChatMessage.append("user", "why is the sky blue?")
    |> Ollamex.ChatMessage.append("assistant", "due to rayleigh scattering!")
    |> Ollamex.ChatMessage.append("user", "how is that different to Mie scattering?")
    |> Enum.map(&Map.from_struct(&1))
  iex>
  [
  %{content: "why is the sky blue?", images: [], role: "user"},
  %{content: "due to rayleigh scattering!", images: [], role: "assistant"},
  %{
    content: "how is that different to Mie scattering?",
    images: [],
    role: "user"
  }
  ]

  iex> cr = %Ollamex.ChatRequest{messages: messages, model: "llama2", stream: true}
  %Ollamex.ChatRequest{
    model: "llama2",
    messages: [
      %{content: "why is the sky blue?", images: [], role: "user"},
      %{content: "due to rayleigh scattering!", images: [], role: "assistant"},
      %{
        content: "how is that different to Mie scattering?",
        images: [],
        role: "user"
      }
    ],
    format: nil,
    options: nil,
    template: nil,
    stream: true
  }
  iex> Ollamex.chat_with_timeout(cr, api)
  {:ok,
   %Ollamex.LLMResponse{
    context: nil,
    created_at: "2024-01-10T19:29:05.771371091Z",
    done: true,
    eval_count: 515,
    eval_duration: 83246108000,
    model: "llama2",
    prompt_eval_count: 61,
    prompt_eval_duration: 7234332000,
    response: nil,
    total_duration: 95606709630,
    message: %{
      content: "Mie scattering is [...] while Rayleigh scattering
      is responsible for the reddening of sunlight at sunrise
      and sunset.",
      role: "assistant"
    },
    errors: nil
  }}
  ```

  ### Generate embeddings (`/embeddings` endpoint)

  ```elixir
  iex> p = %Ollamex.PromptRequest{model: "llama2", prompt: "Explain the main features and benefits of the Elixir programming language in a single, concise paragraph."}
  %Ollamex.PromptRequest{
    model: "llama2",
    prompt: "Explain the main features and benefits of the Elixir programming language in a single, concise paragraph.",
    raw: false,
    format: nil,
    stream: true,
    options: nil,
    images: []
  }
  iex> Ollamex.embeddings(p, api)
  %Ollamex.LLMResponse{
    context: nil,
    created_at: nil,
    done: nil,
    eval_count: nil,
    eval_duration: nil,
    model: "llama2",
    prompt_eval_count: nil,
    prompt_eval_duration: nil,
    response: nil,
    total_duration: nil,
    message: nil,
    embedding: [-1.6268974542617798, -1.4279855489730835, -0.46105068922042847,
    0.7557640671730042, -0.17748284339904785, ...],
    errors: nil
  }
  ```
  """
  @moduledoc since: "0.1.0"

  alias Ollamex.{Helpers, API, LLMResponse, PromptRequest, ChatRequest}

  defp prompt(request, endpoint, %API{} = api)
       when is_struct(request) and is_bitstring(endpoint) do
    req = Req.new(base_url: api.uri)

    results =
      Req.post(req,
        url: Path.join("/", endpoint),
        json: Map.from_struct(request),
        receive_timeout: api.timeout,
        into: []
      )

    case results do
      {:error, reason} ->
        %LLMResponse{errors: reason}

      {:ok, %Req.Response{status: 200, body: body}} ->
        Helpers.handle_response(body)
    end
  end

  @doc """
  [Generate a completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion) using the `/generate` endpoint of the ollama API.

  Note that this doesn't guard against situations in which the LLM keeps generating nonsense forever, such as a stream of newlines or tab characters.
  """
  @doc since: "0.1.0"
  def generate(%PromptRequest{} = request, %API{} = api) do
    prompt(request, "generate", api)
  end

  @doc """
  Same functionality as `generate/2`, but will shutdown the task after the provided `timeout` (in milliseconds, default value `120_000`).
  """
  @doc since: "0.1.0"

  def generate_with_timeout(%PromptRequest{} = request, %API{} = api, timeout \\ 120_000)
      when is_integer(timeout) do
    Helpers.create_task(&generate/2, [request, api])
    |> Helpers.yield_or_timeout_and_shutdown(timeout)
  end

  @doc """
  [Generate a chat completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion) using the `/chat` endpoint of the ollama API.

  Note that this doesn't guard against situations in which the LLM keeps generating nonsense forever, such as a stream of newlines or tab characters.
  """
  @doc since: "0.1.0"
  def chat(%ChatRequest{} = request, %API{} = api) do
    prompt(request, "chat", api)
  end

  @doc """
  Same functionality as `chat/2`, but will shutdown the task after the provided `timeout` (in milliseconds, default value `120_000`).
  """
  @doc since: "0.1.0"
  def chat_with_timeout(%ChatRequest{} = request, %API{} = api, timeout \\ 120_000)
      when is_integer(timeout) do
    Helpers.create_task(&chat/2, [request, api])
    |> Helpers.yield_or_timeout_and_shutdown(timeout)
  end

  @doc """
  [Generate embeddings](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-embeddings) from an LLM using the `/embeddings` endpoint of the ollama API.
  """
  @doc since: "0.2.0"
  def embeddings(%PromptRequest{} = request, %API{} = api) do
    r = prompt(request, "embeddings", api)
    %LLMResponse{errors: errors} = r

    case errors do
      nil -> %{r | model: request.model}
      _ -> r
    end
  end

  @doc """
  Same functionality as `embeddings/2`, but will shutdown the task after the provided `timeout` (in milliseconds, default value `120_000`).
  """
  @doc since: "0.2.0"
  def embeddings_with_timeout(%PromptRequest{} = request, %API{} = api, timeout \\ 120_000)
      when is_integer(timeout) do
    Helpers.create_task(&embeddings/2, [request, api])
    |> Helpers.yield_or_timeout_and_shutdown(timeout)
  end
end
