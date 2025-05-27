defmodule ChatxWeb.ChatLive.Index do
  alias Chatx.Chat
  use ChatxWeb, :live_view

  alias ChatxWeb.Presence

  def mount(_params, _session, socket) do
    %{user_name: user_name} = socket.assigns

    if connected?(socket) do
      # Chatx.Chat.ChatServer.add_message("Hello guys", "masid")
      # Chatx.Chat.ChatServer.add_message("Where are you?", "masid")

      if user_name do
        Presence.track_user(user_name)
        Presence.subscribe()
      end
    end

    recent_messages = Chat.list_recent_messages()

    # IO.inspect(recent_messages)

    online_users_count = count_other_users()

    socket =
      socket
      |> assign(:page_title, "#{online_users_count} users")
      |> assign(:online_users_count, online_users_count)
      |> assign(:new_message, "")
      |> stream(:message, recent_messages, reset: true)

    {:ok, socket, layout: false}
  end

  def handle_info({:user_joined, _presence}, socket) do
    online_users_count = count_other_users()

    socket =
      socket
      |> assign(:online_users_count, online_users_count)
      |> assign(:page_title, "#{online_users_count} users")

    {:noreply, socket}
  end

  def handle_info({:user_left, _presence}, socket) do
    online_users_count = count_other_users()

    socket =
      socket
      |> assign(:online_users_count, online_users_count)
      |> assign(:page_title, "#{online_users_count} users")

    {:noreply, socket}
  end

  defp count_other_users do
    # Not count current user
    Presence.count_users() - 1
  end

  def render(assigns) do
    ~H"""
    <div>
      <header class="px-4 sm:px-6 lg:px-8 border-b border-zinc-100">
        <div class="flex items-center justify-between py-3 text-sm">
          <a href="/" class="flex gap-2 items-center">
            <.icon name="hero-chat-bubble-left-right" class="size-6" /> Chatx
          </a>
          <div class="flex items-center gap-7">
            <div class="flex items-center gap-2 relative">
              <p>
                <%= cond do %>
                  <% @online_users_count == 0 -> %>
                    Just you in the room
                  <% @online_users_count == 1 -> %>
                    1 user online
                  <% true -> %>
                    {@online_users_count} users online
                <% end %>
              </p>
              <div class="absolute -top-1 -right-1">
                <div class="size-2 bg-green-500 rounded-full" />
                <div class="absolute inset-0 size-2 bg-green-500 rounded-full animate-ping" />
              </div>
            </div>
            <.link
              href={~p"/users/leave-chat"}
              method="delete"
              class="rounded-lg border border-black size-8 leading-none hover:text-red-500 hover:border-red-500 hover:bg-red-100 flex items-center justify-center"
              title="Leave chat"
            >
              <.icon name="hero-arrow-right-start-on-rectangle" class="size-4" />
            </.link>
          </div>
        </div>
      </header>
      <main class="px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-2xl">
          <.flash_group flash={@flash} />
          <h2>Chat - Logged in as {@user_name}</h2>
          <div id="messages" phx-update="stream" class="space-y-4 mb-8">
            <div
              :for={{dom_id, message} <- @streams.message}
              id={dom_id}
              class="border-l-4 border-blue-500 pl-4"
            >
              <div class="flex items-center gap-2 text-sm text-gray-600">
                <span class="font-medium">{message.author}</span>
                <span>•</span>
                <time>{Calendar.strftime(message.inserted_at, "%H:%M")}</time>
              </div>
              <p class="mt-1">{message.content}</p>
            </div>
          </div>
          <.link navigate={~p"/"} class="text-blue-500">Home</.link>
        </div>
      </main>
    </div>
    """
  end
end
