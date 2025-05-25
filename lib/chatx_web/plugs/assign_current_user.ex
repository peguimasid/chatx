defmodule ChatxWeb.Plugs.AssignCurrentUser do
  @moduledoc """
  Assigns the current user name from the session to socket assigns.
  Similar to how Phoenix authentication works.
  """

  import Phoenix.Component

  def on_mount(:assign_current_user, _params, session, socket) do
    user_name = session["user_name"]
    socket = assign(socket, :user_name, user_name)
    {:cont, socket}
  end
end
