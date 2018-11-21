defmodule <%= base %>Web.Auth.Utils do
  @moduledoc """
  Helper functions for authentication.
  """

  alias <%= base %>.Sessions

  @doc """
  Adds session data to the database.

  This function is used by Phauxth.Remember.
  """
  def create_session(%Plug.Conn{assigns: %{current_user: %{id: user_id}}}) do
    Sessions.create_session(%{user_id: user_id})
  end
end
