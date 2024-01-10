# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.LLMResponse do
  @moduledoc """
  The struct describing a response from an LLM on ollama, covering the fields that both the `/generate` and the `/chat` endpoints of the REST API return.
  """
  @moduledoc since: "0.1.0"
  defstruct [
    :context,
    :created_at,
    :done,
    :eval_count,
    :eval_duration,
    :model,
    :prompt_eval_count,
    :prompt_eval_duration,
    :response,
    :total_duration,
    :message,
    :errors
  ]
end
