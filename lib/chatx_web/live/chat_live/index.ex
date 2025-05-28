defmodule ChatxWeb.ChatLive.Index do
  alias Chatx.Chat
  use ChatxWeb, :live_view

  alias ChatxWeb.Presence

  def mount(_params, _session, socket) do
    %{user_name: user_name} = socket.assigns

    if connected?(socket) do
      # Chatx.Chat.ChatServer.add_message("Hello guys", "masid")
      # Chatx.Chat.ChatServer.add_message("Where are you?", "gmasid")

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
      <footer class="sticky bottom-0 z-10 flex min-h-14 w-full justify-center bg-white">
        <div class="max-w-2xl w-full border h-10 rounded-lg">Simulate input</div>
      </footer>
    </div>
    """
  end
end
