defmodule ChatxWeb.HomeLive.Index do
  use ChatxWeb, :live_view

  alias ChatxWeb.Presence

  def mount(_params, session, socket) do
    user_name = session["user_name"]
    form = to_form(%{"name" => ""}, as: "user")

    if connected?(socket) do
      Presence.subscribe()
    end

    online_users_count = Presence.count_users()

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_name, user_name)
      |> assign(:form, form)
      |> assign(:online_users_count, online_users_count)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_info({:user_joined, _presence}, socket) do
    online_users_count = Presence.count_users()
    {:noreply, assign(socket, :online_users_count, online_users_count)}
  end

  def handle_info({:user_left, _presence}, socket) do
    online_users_count = Presence.count_users()
    {:noreply, assign(socket, :online_users_count, online_users_count)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    online_users = Presence.list_users()
    name = String.trim(user_params["name"])
    name_exists = Enum.any?(online_users, fn user -> user.user_name == name end)

    form =
      if name_exists do
        user_params
        |> to_form(as: "user")
        |> Map.put(:errors, name: {"User with that name is already in the chat", []})
      else
        to_form(user_params, as: "user")
      end

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("join_chat", %{"user" => user_params}, socket) do
    online_users = Presence.list_users()
    name = String.trim(user_params["name"])
    name_exists = Enum.any?(online_users, fn user -> user.user_name == name end)

    if name_exists do
      form =
        user_params
        |> to_form(as: "user")
        |> Map.put(:errors, name: {"User with that name is already in the chat", []})

      {:noreply, assign(socket, :form, form)}
    else
      {:noreply, assign(socket, trigger_submit: true)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-10 md:mt-20">
      <div class="rounded-lg border p-6">
        <div class="flex items-center justify-center mb-4">
          <div class="flex items-center gap-2 px-3 py-1.5 bg-green-50 border border-green-200 rounded-full text-sm text-green-700">
            <span class="font-medium">{@online_users_count}</span>
            <span>user{if @online_users_count != 1, do: "s"} online</span>
            <div class="relative">
              <div class="size-2 bg-green-500 rounded-full" />
              <div class="absolute inset-0 size-2 bg-green-500 rounded-full animate-ping" />
            </div>
          </div>
        </div>

        <h2 class="text-2xl font-bold mb-6 text-center">Welcome to Chatx</h2>
        <%= if @user_name do %>
          <div class="text-center space-y-4">
            <p>Welcome back, <strong><%= @user_name %></strong>!</p>
            <.link
              navigate={~p"/chat"}
              class="w-full bg-zinc-900 hover:bg-zinc-700 text-white py-2 px-6 rounded-lg inline-block text-center"
            >
              Continue to Chat
            </.link>
            <.link
              href={~p"/users/leave-chat"}
              method="delete"
              class="block w-full mt-2 text-sm text-gray-600 hover:text-gray-800"
            >
              Use different name
            </.link>
          </div>
        <% else %>
          <.simple_form
            for={@form}
            id="join_form"
            action={~p"/users/join-chat"}
            phx-change="validate"
            phx-submit="join_chat"
            phx-trigger-action={@trigger_submit}
          >
            <.input
              field={@form[:name]}
              type="text"
              label="Enter your name:"
              placeholder="Your name..."
              autocomplete="off"
              required
            />

            <:actions>
              <.button class="w-full" phx-disable-with="Joining...">
                Join Chat <span aria-hidden="true">→</span>
              </.button>
            </:actions>
          </.simple_form>
        <% end %>
      </div>
    </div>
    """
  end
end
