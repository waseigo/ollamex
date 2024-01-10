# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.LLModel do
  @moduledoc """
  The struct describing a Large Language Model on ollama.
  """
  @moduledoc since: "0.1.0"
  @enforce_keys [:name, :digest, :modified_at, :size]
  defstruct [:name, :digest, :modified_at, :size, :details, :modelfile, :parameters, :template]
end
