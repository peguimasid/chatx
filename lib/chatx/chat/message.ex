defmodule Chatx.Chat.Message do
  @moduledoc """
  Message struct for chat messages.
  """

  defstruct [:id, :content, :user_name, :inserted_at]

  def new(content, user_name) do
    %__MODULE__{
      id: System.unique_integer([:positive]),
      content: String.trim(content),
      user_name: user_name,
      inserted_at: DateTime.utc_now()
    }
  end

  def valid?(%__MODULE__{content: content}) when is_binary(content) do
    String.length(String.trim(content)) > 0 and String.length(content) <= 500
  end

  def valid?(_), do: false
end
