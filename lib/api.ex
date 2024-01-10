# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.API do
  @moduledoc """
  Defines the struct for the parameters of the ollama REST API and provides helper functions for initializing a struct, updating the list of models, and generating a list of models available by the API.
  """
  @moduledoc since: "0.1.0"

  alias Ollamex.{Helpers, API, LLModel}

  defstruct uri: "http://localhost:11434/api", models: nil, timeout: 120_000, errors: []

  @doc """
  Lazy way of creating a new struct with default values (incl. an URL of `http://localhost:11434/api`), instead of `%Ollamex.API{}`, that also fetches the list of available LLMs from the ollama REST API.
  """
  @doc since: "0.1.0"
  def new() do
    %API{} |> update_models()
  end

  @doc """
  Same as `new/0`, but can be provided with a string representing the full URL of an ollama REST API.
  """
  @doc since: "0.1.0"
  def new(uri) when is_bitstring(uri) do
    %API{uri: uri}
    |> update_models()
  end

  @doc """
  Returns the provided `%Ollama.API{}` struct, enriched with the available LLMs from the ollama REST API `api` as a list of `%Ollama.LLModel{}` structs in the `:models` parameter.
  """
  @doc since: "0.1.0"
  def update_models(%API{} = api) do
    req = Req.new(base_url: api.uri)
    results = Req.get(req, url: "/tags")

    case results do
      {:error, reason} ->
        %{api | errors: api.errors ++ reason}

      {:ok, %Req.Response{status: 200, body: body}} ->
        models =
          body["models"]
          |> Enum.map(&Helpers.map_to_struct(&1, LLModel))

        %{api | models: models}
    end
  end

  @doc """
  Returns a flat list of available LLMs from the ollama REST API `api`.
  """
  @doc since: "0.1.0"
  def list_models(%API{} = api) do
    api.models |> Enum.map(fn m -> m.name end)
  end
end
