defmodule ChatxWeb.HomeLive.Index do
  use ChatxWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Home")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2>Home</h2>
      <.link navigate={~p"/chat"} class="text-blue-500">Chat</.link>
    </div>
    """
  end
end
