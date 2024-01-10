# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.PromptRequest do
  @moduledoc """
  Defines the struct of a request to the `/generate` endpoint of the ollama API.
  """
  @moduledoc since: "0.1.0"
  @enforce_keys [:model]
  defstruct model: nil,
            prompt: nil,
            raw: false,
            format: nil,
            stream: true,
            options: nil,
            images: []
end
