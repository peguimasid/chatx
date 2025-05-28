defmodule ChatxWeb.ChatLive.Index do
  alias Chatx.Chat
  use ChatxWeb, :live_view

  alias ChatxWeb.Presence

  def mount(_params, _session, socket) do
    %{user_name: user_name} = socket.assigns

    if connected?(socket) do
      # Chatx.Chat.ChatServer.add_message("Hello guys", "masid")
      # Chatx.Chat.ChatServer.add_message("Where are you?", "gmasid")
      Presence.track_user(user_name)
      Presence.subscribe()
      Chat.subscribe()
    end

    recent_messages = Chat.list_recent_messages()
    online_users_count = count_other_users()

    socket =
      socket
      |> assign(:page_title, "#{online_users_count} users")
      |> assign(:online_users_count, online_users_count)
      |> assign(:new_message, "")
      |> stream(:message, recent_messages, reset: true)

    {:ok, socket, layout: false}
  end

  def handle_event("send_message", %{"message" => message_content}, socket) do
    %{user_name: user_name} = socket.assigns

    if String.trim(message_content) != "" do
      Chatx.Chat.ChatServer.add_message(message_content, user_name)
    end

    {:noreply, assign(socket, :new_message, "")}
  end

  def handle_event("form_change", %{"message" => message_content}, socket) do
    {:noreply, assign(socket, :new_message, message_content)}
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

  def handle_info({:new_message, message}, socket) do
    {:noreply, stream_insert(socket, :message, message)}
  end

  defp count_other_users do
    Presence.count_users() - 1
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-screen w-screen overflow-auto">
      <header class="sticky inset-0 z-10 px-4 sm:px-6 lg:px-8 border-b border-zinc-100">
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
      <main class="size-full overflow-auto px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-2xl">
          <.flash_group flash={@flash} />
          <div id="messages" phx-update="stream" class="space-y-4 mb-8">
            <div
              :for={{dom_id, message} <- @streams.message}
              id={dom_id}
              class={[
                "flex",
                if(message.author == @user_name, do: "justify-end", else: "justify-start")
              ]}
            >
              <div class={[
                "max-w-xs lg:max-w-md",
                if(message.author == @user_name,
                  do: "flex flex-row-reverse items-start gap-3",
                  else: "flex items-start gap-3"
                )
              ]}>
                <div class="size-8 bg-zinc-500 rounded-full flex items-center justify-center text-white text-sm font-medium flex-shrink-0">
                  <p class="m-0 p-0">
                    {String.first(message.author) |> String.upcase()}
                  </p>
                </div>
                <div>
                  <div class="flex items-center justify-end gap-1 text-sm text-gray-600">
                    <span class="font-medium">
                      {if message.author == @user_name, do: "You", else: message.author}
                    </span>
                    <span>•</span>
                    <time>{Calendar.strftime(message.inserted_at, "%H:%M")}</time>
                  </div>
                  <p class="mt-1">{message.content}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
      <footer class="sticky bottom-0 z-10 flex w-full justify-center items-center min-h-14">
        <div class="max-w-2xl w-full">
          <.form
            for={%{}}
            as={:message}
            phx-submit="send_message"
            phx-change="form_change"
            class="size-full flex items-center"
          >
            <input
              name="message"
              value={@new_message}
              placeholder="Type your message..."
              class="mt-0 block w-full px-3 py-2 rounded-lg text-zinc-900 border border-zinc-300 focus:border-zinc-400 focus:ring-0 sm:text-sm sm:leading-6"
              autocomplete="off"
            />
            <button
              type="submit"
              class="ml-2 px-4 py-2 bg-black border border-black text-white rounded-lg w-20 flex-shrink-0 hover:bg-zinc-800"
            >
              Send
            </button>
          </.form>
        </div>
      </footer>
    </div>
    """
  end
end
