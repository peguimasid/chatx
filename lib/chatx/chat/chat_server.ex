defmodule Chatx.Chat.ChatServer do
  @moduledoc """
  GenServer for managing chat messages in memory.
  Stores the most recent 20 messages.
  """

  use GenServer
  require Logger
  alias Chatx.Chat.Message

  @name __MODULE__

  defmodule State do
    defstruct cache_size: 20, messages: []
  end

  def start_link(_opts) do
    Logger.info("Starting chat server...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def add_message(content, user_name) do
    GenServer.call(@name, {:add_message, content, user_name})
  end

  def recent_messages() do
    GenServer.call(@name, :recent_messages)
  end

  # Server callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call(:recent_messages, _from, state) do
    # Return messages in chronological order (oldest first) for display
    messages = Enum.reverse(state.messages)
    {:reply, messages, state}
  end

  def handle_call({:add_message, content, user_name}, _from, state) do
    message = Message.new(content, user_name)

    case Message.valid?(message) do
      true ->
        # Store messages with newest first, then limit to cache_size
        new_messages =
          [message | state.messages]
          |> Enum.take(state.cache_size)

        new_state = %{state | messages: new_messages}
        {:reply, {:ok, message}, new_state}

      false ->
        {:reply, {:error, :invalid_message}, state}
    end
  end
end
