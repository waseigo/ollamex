# SPDX-FileCopyrightText: 2024 Isaak Tsalicoglou <isaak@waseigo.com>
# SPDX-License-Identifier: Apache-2.0

defmodule Ollamex.ChatMessage do
  @moduledoc """
  Defines the struct used to store data of a chat message and provides helper functions to create a list of chat messages using the pipeline operator.
  """
  @moduledoc since: "0.1.0"
  @enforce_keys [:role, :content]
  defstruct role: "user",
            content: nil,
            images: []

  def create(role, content, images \\ [])

  @doc """
  Create the first message (`%Ollamex.ChatMessage{}`) in a list.
  """
  @doc since: "0.1.0"
  def create(role, content, images)
      when is_bitstring(role) and is_bitstring(content) and is_list(images) do
    valid_roles = ["system", "user", "assistant"]

    if role in valid_roles do
      {:ok, %Ollamex.ChatMessage{role: role, content: content, images: images}}
    else
      {:error, "Given role #{role} not one of " <> Enum.join(valid_roles, ", ")}
    end
  end

  @doc """
  Append a message (`%Ollamex.ChatMessage{}`) to a list of existing ones.
  """
  @doc since: "0.1.0"
  def append(cm, role, content, images \\ [])

  def append({:ok, %Ollamex.ChatMessage{} = cm}, role, content, images) do
    next = create(role, content, images)

    case next do
      {:ok, new_cm} -> [cm] ++ [new_cm]
      {:error, _} -> [cm]
    end
  end

  def append(cmlist, role, content, images) when is_list(cmlist) do
    next = create(role, content, images)

    case next do
      {:ok, new_cm} -> cmlist ++ [new_cm]
      {:error, _} -> cmlist
    end
  end
end
