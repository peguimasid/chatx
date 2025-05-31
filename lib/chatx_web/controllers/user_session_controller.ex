defmodule ChatxWeb.UserSessionController do
  use ChatxWeb, :controller

  def create(conn, %{"user" => %{"name" => name}}) do
    name = String.trim(name)

    if String.length(name) > 0 do
      conn
      |> put_session(:user_name, name)
      |> redirect(to: ~p"/chat")
    else
      conn
      |> put_flash(:error, "Name cannot be empty")
      |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_name)
    |> put_flash(:info, "You have left the chat.")
    |> redirect(to: ~p"/")
  end
end
