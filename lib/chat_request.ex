# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.ChatRequest do
  @moduledoc """
  Defines the struct of a request to the `/chat` endpoint of the ollama API.
  """
  @moduledoc since: "0.1.0"
  @enforce_keys [:model]
  defstruct model: nil,
            messages: [],
            format: nil,
            options: nil,
            template: nil,
            stream: false
end
