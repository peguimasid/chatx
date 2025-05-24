defmodule ChatxWeb.ChatLive.Index do
  use ChatxWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "8 users")

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div>
      <header class="px-4 sm:px-6 lg:px-8 border-b border-zinc-100">
        <div class="flex items-center justify-between py-3 text-sm">
          <a href="/" class="flex gap-2 items-center">
            <.icon name="hero-chat-bubble-left-right" class="size-6" /> Chatx
          </a>
          <div class="flex items-center gap-4">
            <p>8 users online</p>
            <button class="rounded-lg border border-black size-8 leading-none hover:text-red-500 hover:border-red-500 hover:bg-red-100">
              <.icon name="hero-arrow-right-start-on-rectangle" class="size-4" />
            </button>
          </div>
        </div>
      </header>
      <main class="px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-2xl">
          <.flash_group flash={@flash} />
          <h2>Chat</h2>
          <.link navigate={~p"/"} class="text-blue-500">Home</.link>
        </div>
      </main>
    </div>
    """
  end
end
