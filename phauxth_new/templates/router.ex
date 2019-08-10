defmodule <%= base %>Web.Router do
  use <%= base %>Web, :router<%= if api do %>

  pipeline :api do
    plug :accepts, ["json"]
    plug Phauxth.AuthenticateToken
  end

  scope "/api", <%= base %>Web do
    pipe_through :api

    post "/sessions", SessionController, :create
    resources "/users", UserController, except: [:new, :edit]<%= if confirm do %>
    get "/confirms", ConfirmController, :index
    post "/password_resets", PasswordResetController, :create
    put "/password_resets/update", PasswordResetController, :update<% end %>
  end<% else %>

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate<%= if remember do %>
    plug Phauxth.Remember, create_session_func: &<%= base %>Web.Auth.Utils.create_session/1<% end %>
  end

  scope "/", <%= base %>Web do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]<%= if confirm do %>
    get "/confirms", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update<% end %>
  end<% end %><%= if confirm do %>

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end<% end %>
end
