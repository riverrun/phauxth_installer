defmodule <%= base %>Web.SessionController do
  use <%= base %>Web, :controller

  import <%= base %>Web.Authorize
<%= if not confirm do %>
  alias Phauxth.Login<% end %><%= if remember do %>
  alias Phauxth.Remember<% end %><%= if api do %>
  alias <%= base %>.Sessions<% else %>
  alias <%= base %>.{Sessions, Sessions.Session}<% end %><%= if confirm do %>
  alias <%= base %>Web.Auth.Login<% end %><%= if api do %>
  alias <%= base %>Web.Auth.Token

  # the following plug is defined in the controllers/authorize.ex file
  plug :guest_check when action in [:create]<% else %>

  plug :guest_check when action in [:new, :create]

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
        token = Token.sign(%{"session_id" => session_id})
        render(conn, "info.json", %{info: token})
      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>
        conn
        |> add_session(user, params)
        |> put_flash(:info, "User successfully logged in.")
        |> redirect(to: get_session(conn, :request_path) || Routes.user_path(conn, :index))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))<% end %>
    end
  end<%= if not api do %>

  def delete(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"id" => session_id}) do
    case Sessions.get_session(session_id) do
      %Session{user_id: ^user_id} = session ->
        Sessions.delete_session(session)
        conn
        |> delete_session(:phauxth_session_id)<%= if remember do %>
        |> Remember.delete_rem_cookie()<% end %>
        |> put_flash(:info, "User successfully logged out.")
        |> redirect(to: Routes.page_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  defp add_session(conn, user, <%= if not remember do %>_<% end %>params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)<%= if remember do %>
    |> add_remember_me(user.id, params)<% end %>
  end<%= if remember do %>

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn<% end %><% end %>
end
