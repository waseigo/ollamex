# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.Helpers do
  @moduledoc """
  Module containing helper functions used by the other modules of Ollamex.
  """
  @moduledoc since: "0.1.0"

  alias Ollamex.LLMResponse

  defp at_least_one(key, r) when is_list(r) and is_bitstring(key) do
    r
    |> Enum.filter(fn x -> key in Map.keys(x) end)
    |> length()
    |> Kernel.>(0)
  end

  @doc """
  Because the body of the responses of the `/generate`, `/chat` and `/embeddings` endpoints of the Ollama REST API return different data structures, this helper function detects the endpoint from which a list of responses originated.
  """
  @doc since: "0.2.0"
  def detect_endpoint(r) when is_list(r) do
    lookup = %{
      "response" => :generate,
      "message" => :chat,
      "embedding" => :embeddings
    }

    lookup
    |> Map.keys()
    |> Enum.map(&at_least_one(&1, r))
    |> Enum.find_index(&(&1 == true))
    |> (&Enum.at(Map.values(lookup), &1)).()
  end

  def handle_response(body) do
    r =
      body
      |> Enum.map(&Jason.decode!(&1))
      |> Enum.to_list()

    case detect_endpoint(r) do
      :generate ->
        r |> consolidate_responses()

      :chat ->
        r |> consolidate_responses()

      :embeddings ->
        %{%LLMResponse{} | embedding: hd(r)["embedding"]}
    end
  end

  @doc """
  Consolidates a list of `%Ollamex.LLMResponse{}` structs into a single response, dealing with `stream: false` and `stream: true`, regardless of the origin of the responses (`/chat` or `/generate`).
  """
  @doc since: "0.1.0"
  def consolidate_responses(r) when is_list(r) do
    rs = r |> Enum.map(&map_to_struct(&1, LLMResponse))

    response_done =
      rs
      |> Enum.filter(fn %LLMResponse{done: done} -> done end)

    case Enum.empty?(response_done) do
      true ->
        {:error, "Streamed response was never done."}

      false ->
        if detect_endpoint(r) == :chat do
          %{
            hd(response_done)
            | message: %{role: "assistant", content: extract_messages(rs)}
          }
        else
          %{hd(response_done) | response: extract_responses(rs)}
        end
    end
  end

  @doc """
  Extracts the chat message fragments from a list of `%Ollamex.LLMResponse{}` from the `/chat` endpoint and concatenates them into a string.
  """
  @doc since: "0.1.0"
  def extract_messages(r) when is_list(r) do
    r
    |> Enum.map(fn r ->
      if is_nil(r.message) do
        ""
      else
        r.message["content"]
      end
    end)
    |> List.to_string()
  end

  @doc """
  Extracts the response fragments from a list of `%Ollamex.LLMResponse{}` from the `/generate` endpoint and concatenates them into a string.
  """
  @doc since: "0.1.0"
  def extract_responses(r) when is_list(r) do
    r
    |> Enum.map(fn r -> r.response end)
    |> List.to_string()
  end

  @doc """
  Converts a map to a target struct, so that API responses can be converted to Ollamex structs.
  """
  @doc since: "0.1.0"
  def map_to_struct(source, target) when is_map(source) do
    source
    |> Map.keys()
    |> Enum.map(&String.to_atom(&1))
    |> Enum.zip(Map.values(source))
    |> (&struct(target, &1)).()
  end

  @doc """
  Creates an async task from the provided function `fun` with arguments `args`.
  """
  @doc since: "0.1.0"
  def create_task(fun, args) do
    Task.async(fn -> apply(fun, args) end)
  end

  @doc """
  Yields the result of a task if within the provided `timeout` (in milliseconds, default value `120_000`), or shuts the task down.

  Utilized by the `Ollamex.generate_with_timeout/2`, `Ollamex.generate_with_timeout/3`, `Ollamex.chat_with_timeout/2` and `Ollamex.chat_with_timeout/3` functions to deal with cases where the LLM keeps going on and on with repetition.
  """
  @doc since: "0.1.0"
  def yield_or_timeout_and_shutdown(task, timeout \\ 120_000) do
    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, result} ->
        {:ok, result}

      nil ->
        {:error, :timeout}

      {:exit, :noproc} ->
        {:error, :noproc}
    end
  end
end
