defmodule <%= base %>Web.UserControllerTest do
  use <%= base %>Web.ConnCase

  import <%= base %>Web.AuthTestHelpers

  alias <%= base %>.Accounts

  @create_attrs %{email: "bill@example.com", password: "hard2guess"}
  @update_attrs %{email: "william@example.com"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} do<%= if not api do %>
    conn = conn |> bypass_through(<%= base %>Web.Router, [:browser]) |> get("/")<% end %>
    {:ok, %{conn: conn}}
  end

  describe "index" do
    test "lists all entries on index", %{conn: conn} do
      user = add_user("reg@example.com")<%= if api do %>
      conn = conn |> add_token_conn(user)
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)<% else %>
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing users"<% end %>
    end

    test "renders /users error for nil user", %{conn: conn}  do
      conn = get(conn, Routes.user_path(conn, :index))<%= if api do %>
      assert json_response(conn, 401)<% else %>
      assert redirected_to(conn) == Routes.session_path(conn, :new)<% end %>
    end
  end<%= if not api do %>

  describe "renders forms" do
    setup [:add_user_session]

    test "renders form for new users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New user"
    end

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit user"
    end
  end<% end %>

  describe "show user resource" do
    setup [:add_user_session]

    test "show chosen user's page", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))<%= if api do %>
      assert json_response(conn, 200)["data"] == %{"id" => user.id, "email" => "reg@example.com"}<% else %>
      assert html_response(conn, 200) =~ "Show user"<% end %>
    end

    test "returns 404 when user not found", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, -1))
      end
    end
  end

  describe "create user" do
    test "creates user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)<%= if api do %>
      assert json_response(conn, 201)["data"]["id"]
      assert Accounts.get_by(%{"email" => "bill@example.com"})<% else %>
      assert redirected_to(conn) == Routes.session_path(conn, :new)<% end %>
    end

    test "does not create user and renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)<%= if api do %>
      assert json_response(conn, 422)["errors"] != %{}<% else %>
      assert html_response(conn, 200) =~ "New user"<% end %>
    end
  end

  describe "updates user" do
    setup [:add_user_session]

    test "updates chosen user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)<%= if api do %>
      assert json_response(conn, 200)["data"]["id"] == user.id<% else %>
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)<% end %>
      updated_user = Accounts.get_user!(user.id)
      assert updated_user.email == "william@example.com"<%= if not api do %>
      conn = get conn,(Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "william@example.com"<% end %>
    end

    test "does not update chosen user and renders errors when data is invalid", %{
      conn: conn,
      user: user
    } do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)<%= if api do %>
      assert json_response(conn, 422)["errors"] != %{}<% else %>
      assert html_response(conn, 200) =~ "Edit user"<% end %>
    end
  end

  describe "delete user" do
    setup [:add_user_session]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))<%= if api do %>
      assert response(conn, 204)<% else %>
      assert redirected_to(conn) == Routes.session_path(conn, :new)<% end %>
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end<%= if api do %>

    test "cannot delete other user", %{conn: conn} do<% else %>

    test "cannot delete other user", %{conn: conn, user: user} do<% end %>
      other = add_user("tony@example.com")
      conn = delete(conn, Routes.user_path(conn, :delete, other))<%= if api do %>
      assert json_response(conn, 403)["errors"]["detail"] =~ "not authorized"<% else %>
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)<% end %>
      assert Accounts.get_user!(other.id)
    end
  end

  defp add_user_session(%{conn: conn}) do
    user = add_user("reg@example.com")<%= if api do %>
    conn = conn |> add_token_conn(user)<% else %>
    conn = conn |> add_session(user) |> send_resp(:ok, "/")<% end %>
    {:ok, %{conn: conn, user: user}}
  end
end
