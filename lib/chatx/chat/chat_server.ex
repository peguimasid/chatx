defmodule Chatx.Chat.ChatServer do
  @moduledoc """
  GenServer for managing chat messages in memory.
  Stores the most recent 20 messages.
  """

  use GenServer
  require Logger
  alias Chatx.Chat
  alias Chatx.Chat.Message

  @name __MODULE__

  defmodule State do
    defstruct cache_size: 20, messages: []
  end

  def start_link(_opts) do
    Logger.info("Starting chat server...")
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def add_message(content, author) do
    GenServer.call(@name, {:add_message, content, author})
  end

  def recent_messages() do
    GenServer.call(@name, :recent_messages)
  end

  # Server callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call(:recent_messages, _from, state) do
    messages = Enum.reverse(state.messages)
    {:reply, messages, state}
  end

  def handle_call({:add_message, content, author}, _from, state) do
    message = Message.new(content, author)

    case Message.valid?(message) do
      true ->
        new_messages =
          [message | state.messages]
          |> Enum.take(state.cache_size)

        Chat.broadcast({:new_message, message})
        new_state = %{state | messages: new_messages}
        {:reply, {:ok, message}, new_state}

      false ->
        {:reply, {:error, :invalid_message}, state}
    end
  end
end
