defmodule <%= base %>Web.PasswordResetController do
  use <%= base %>Web, :controller

  alias Phauxth.Confirm.PassReset
  alias <%= base %>.Accounts
  alias <%= base %>Web.{Auth.Token, Email}<%= if not api do %>

  def new(conn, _params) do
    render(conn, "new.html")
  end<% end %>

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    if Accounts.create_password_reset(%{"email" => email}) do
      key = Token.sign(%{"email" => email})<%= if api do %>
      Email.reset_request(email, Routes.password_reset_url(conn, :update, password_reset: %{key: key}))
    end

    conn
    |> put_status(:created)
    |> put_view(<%= base %>Web.PasswordResetView)
    |> render("info.json", %{info: "Check your inbox for instructions on how to reset your password"})
  end<% else %>
      Email.reset_request(email, Routes.password_reset_url(conn, :edit, key: key))
    end

    conn
    |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end

  def edit(conn, _params) do
    render(conn, <%= base %>Web.ErrorView, "404.html")
  end<% end %>

  def update(conn, %{"password_reset" => params}) do
    case PassReset.verify(params, []) do
      {:ok, user} ->
        user
        |> Accounts.update_password(params)
        |> update_password(conn, params)

      {:error, message} -><%= if api do %>
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(<%= base %>Web.PasswordResetView)
        |> render("error.json", error: message)<% else %>
        conn
        |> put_flash(:error, message)
        |> render("edit.html", key: params["key"])<% end %>
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Email.reset_success(user.email)<%= if api do %>

    conn
    |> put_view(<%= base %>Web.PasswordResetView)
    |> render("info.json", %{info: "Your password has been reset"})<% else %>

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "Your password has been reset")
    |> redirect(to: Routes.session_path(conn, :new))<% end %>
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, <%= if api do %>_<% end %>params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)<%= if api do %>

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(<%= base %>Web.PasswordResetView)
    |> render("error.json", error: message)<% else %>

    conn
    |> put_flash(:error, message || "Invalid input")
    |> render("edit.html", key: params["key"])<% end %>
  end
end
