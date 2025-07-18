defmodule FusionJWTAuthentication.DefaultHandleLogin do
  @moduledoc """
  Login that requires a cas token
  """
  @behaviour FusionJWTAuthentication.HandleLogin

  alias Plug.Conn

  @impl true
  def handle_login(conn, %{"cas_token" => cas_token}) do
    {:ok, Conn.assign(conn, :cas_token, cas_token)}
  end

  def handle_login(conn, _), do: {:ok, conn}
end
