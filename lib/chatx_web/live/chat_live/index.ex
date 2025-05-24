defmodule ChatxWeb.ChatLive.Index do
  use ChatxWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Chat")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2>Chat</h2>
      <.link navigate={~p"/"} class="text-blue-500">Home</.link>
    </div>
    """
  end
end
