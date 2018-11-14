defmodule <%= base %>Web.ConfirmController do
  use <%= base %>Web, :controller<%= if api do %>

  import <%= base %>Web.Authorize<% end %>

  alias Phauxth.Confirm
  alias <%= base %>.Accounts
  alias <%= base %>Web.Email

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        Email.confirm_success(user.email)<%= if api do %>

        conn
        |> put_view(<%= base %>Web.ConfirmView)
        |> render("info.json", %{info: "Your account has been confirmed"})

      {:error, _message} ->
        error(conn, :unauthorized, 401)<% else %>

        conn
        |> put_flash(:info, "Your account has been confirmed")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))<% end %>
    end
  end
end
