defmodule ChatxWeb.HomeLive.Index do
  use ChatxWeb, :live_view

  def mount(_params, session, socket) do
    user_name = session["user_name"]

    form = to_form(%{"name" => ""}, as: "user")

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_name, user_name)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    # TODO: Check if typed name already in the chat
    form = to_form(user_params, as: "user")
    {:noreply, assign(socket, :form, form)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-20">
      <div class="rounded-lg border p-6">
        <h2 class="text-2xl font-bold mb-6 text-center">Welcome to Chatx</h2>

        <%= if @user_name do %>
          <div class="text-center space-y-6">
            <p class="mb-4">Welcome back, <strong><%= @user_name %></strong>!</p>
            <.link
              navigate={~p"/chat"}
              class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded"
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
          <.simple_form for={@form} id="join_form" action={~p"/users/join-chat"} phx-change="validate">
            <.input
              field={@form[:name]}
              type="text"
              label="Enter your name:"
              placeholder="Your name..."
              autocomplete="off"
              required
            />

            <:actions>
              <.button class="w-full">
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
