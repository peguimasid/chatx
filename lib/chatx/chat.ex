defmodule Chatx.Chat do
  @moduledoc """
  The Chat context.
  """

  alias Chatx.Chat.ChatServer

  @chat_topic "chat:messages"

  def list_recent_messages() do
    ChatServer.recent_messages()
  end

  def create_message(content, user_name) do
    ChatServer.add_message(content, user_name)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Chatx.PubSub, @chat_topic)
  end

  def broadcast(message) do
    Phoenix.PubSub.broadcast(Chatx.PubSub, @chat_topic, message)
  end

  def change_message(attrs \\ %{}) do
    # Simple validation for the form
    content = String.trim(Map.get(attrs, "content", ""))
    length = String.length(content)

    %{
      valid?: length > 0 and length <= 500,
      errors: [],
      params: attrs
    }
  end
end
