# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.Helpers do
  @moduledoc """
  Module containing helper functions used by the other modules of Ollamex.
  """
  @moduledoc since: "0.1.0"

  alias Ollamex.LLMResponse

  @doc """
  Determines whether a list of `%Ollamex.LLMResponse{}` structs (only one item if `stream: false`, more than one item if `stream: true` in the request) came from the `/chat` or the `/generate` endpoint.
  """
  @doc since: "0.1.0"
  def is_chat?(responses) when is_list(responses) do
    responses
    |> Enum.filter(fn r -> is_nil(r.message["content"]) end)
    |> Kernel.==(responses)
    |> Kernel.not()
  end

  @doc """
  Consolidates a list of `%Ollamex.LLMResponse{}` structs into a single response, dealing with `stream: false` and `stream: true`, regardless of the origin of the responses (`/chat` or `/generate`).
  """
  @doc since: "0.1.0"
  def consolidate_responses(responses_list) when is_list(responses_list) do
    response_done =
      responses_list
      |> Enum.filter(fn %LLMResponse{done: done} -> done end)

    case Enum.empty?(response_done) do
      true ->
        {:error, "Streamed response was never done."}

      false ->
        if is_chat?(responses_list) do
          %{
            hd(response_done)
            | message: %{role: "assistant", content: extract_messages(responses_list)}
          }
        else
          %{hd(response_done) | response: extract_responses(responses_list)}
        end
    end
  end

  @doc """
  Extracts the chat message fragments from a list of `%Ollamex.LLMResponse{}` from the `/chat` endpoint and concatenates them into a string.
  """
  @doc since: "0.1.0"
  def extract_messages(responses_list) when is_list(responses_list) do
    responses_list
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
  def extract_responses(responses_list) when is_list(responses_list) do
    responses_list
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
