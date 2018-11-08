defmodule <%= base %>Web.ConfirmController do
  use <%= base %>Web, :controller

  alias Phauxth.Confirm
  alias <%= base %>.Accounts
  alias <%= base %>Web.Email

  def index(conn, params) do
    case Confirm.verify(params) do
      {:ok, user} ->
        Accounts.confirm_user(user)
        Email.confirm_success(user.email)<%= if api do %>
        render(conn, <%= base %>Web.ConfirmView, "info.json", %{info: message})

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
