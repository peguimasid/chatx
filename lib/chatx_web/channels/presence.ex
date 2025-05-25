defmodule ChatxWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """

  use Phoenix.Presence,
    otp_app: :chatx,
    pubsub_server: Chatx.PubSub

  @topic "online_users"

  def track_user(user_name) do
    track(self(), @topic, user_name, %{
      online_at: System.system_time(:second)
    })
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Chatx.PubSub, "updates:#{@topic}")
  end

  def list_users do
    list(@topic)
    |> Enum.map(fn {user_name, %{metas: metas}} ->
      %{id: user_name, user_name: user_name, metas: metas}
    end)
  end

  def count_users do
    list(@topic)
    |> Enum.count()
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_name, _presence} <- joins do
      presence = %{id: user_name, user_name: user_name, metas: Map.fetch!(presences, user_name)}
      msg = {:user_joined, presence}
      Phoenix.PubSub.local_broadcast(Chatx.PubSub, "updates:#{topic}", msg)
    end

    for {user_name, _presence} <- leaves do
      metas =
        case Map.fetch(presences, user_name) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      presence = %{id: user_name, user_name: user_name, metas: metas}
      msg = {:user_left, presence}
      Phoenix.PubSub.local_broadcast(Chatx.PubSub, "updates:#{topic}", msg)
    end

    {:ok, state}
  end
end
