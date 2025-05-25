defmodule ChatxWeb.UserSession do
  @moduledoc """
    Handles user session management for Chatx WebSocket connections.

    This module provides LiveView mount hooks for managing user authentication
    and authorization in chat rooms. It extracts user information from the session
    and assigns it to the LiveView socket, enabling real-time chat functionality
    with proper user identification.

    ## Mount Hooks

    - `:assign_current_user` - Assigns the current user name from session to socket assigns
    - `:require_user` - Ensures a user is authenticated, redirects to home if not
  """

  use ChatxWeb, :verified_routes
  import Phoenix.Component

  def on_mount(:assign_current_user, _params, session, socket) do
    user_name = session["user_name"]
    socket = assign(socket, :user_name, user_name)
    {:cont, socket}
  end

  def on_mount(:require_user, _params, session, socket) do
    user_name = session["user_name"]

    if user_name do
      socket = assign(socket, :user_name, user_name)
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "Please provide a name to join the chat.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end
end
