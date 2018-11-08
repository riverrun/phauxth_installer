defmodule <%= base %>Web.SessionController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize

  alias <%= base %>.Sessions<%= if confirm do %>
  alias <%= base %>Web.Auth.Login<% else %>
  alias Phauxth.Login<% end %><%= if api do %>
  alias <%= base %>Web.Auth.Token

  # the following plugs are defined in the controllers/authorize.ex file
  plug :guest_check when action in [:create]<% else %>

  plug :guest_check when action in [:new, :create]
  plug :id_check when action in [:delete]

  def new(conn, _) do
    render(conn, "new.html")
  end<% end %>

  def create(conn, %{"session" => params}) do
    case Login.verify(params) do
      {:ok, user} -><%= if api do %>
        # The Sessions.create_session function is only needed if you are tracking
        # sessions in the database. If you do not want to store session data in the
        # database, remove this line, the <%= base %>.Sessions alias and the
        # <%= base %>.Sessions and <%= base %>.Sessions.Session modules
        {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})
        token = Token.sign(%{session_id: session_id})
        render(conn, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

        conn
        |> delete_session(:request_path)
        |> put_session(:phauxth_session_id, session_id)
        |> configure_session(renew: true)<%= if remember do %>
        |> add_remember_me(user.id, params)<% end %>
        |> put_flash(:info, "User successfully logged in.")
        |> redirect(to: get_session(conn, :request_path) || Routes.user_path(conn, :index))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))<% end %>
    end
  end<%= if not api do %>

  def delete(%Plug.Conn{assigns: %{current_user: _user}} = conn, _) do
    {:ok, _} =
      conn
      |> get_session(:phauxth_session_id)
      |> Sessions.get_session()
      |> Sessions.delete_session()

    conn
    |> delete_session(:phauxth_session_id)<%= if remember do %>
    |> Phauxth.Remember.delete_rem_cookie()<% end %>
    |> put_flash(:info, "User successfully logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end<%= if remember do %>

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Phauxth.Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn<% end %><% end %>
end
