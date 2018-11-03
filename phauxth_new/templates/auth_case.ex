defmodule <%= base %>Web.AuthCase do
  use Phoenix.ConnTest<%= if confirm do %>

  import Ecto.Changeset
  alias <%= base %>.{Accounts, Repo, Sessions}<% else %>

    alias <%= base %>.Accounts<% end %>
<%= if confirm || api do %>
    alias <%= base %>Web.Auth.Token
<% end %>

  def add_user(email) do
    user = %{email: email, password: "reallyHard2gue$$"}
    {:ok, user} = Accounts.create_user(user)
    user
  end<%= if confirm do %>

  def gen_key(email), do: Token.sign(%{"email" => email})

  def add_user_confirmed(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> Repo.update!()
  end

  def add_reset_user(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> change(%{reset_sent_at: now()})
    |> Repo.update!()
  end<% end %><%= if api do %>

  def add_token_conn(conn, user) do
    user_token = Token.sign(%{"user_id" => user.id})

    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end<% else %>

  def add_session(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end<% end %>

  defp now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
