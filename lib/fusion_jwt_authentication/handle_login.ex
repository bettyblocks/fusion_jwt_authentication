defmodule FusionJWTAuthentication.HandleLogin do
  @moduledoc """
  Behaviour for handling login
  """
  @callback handle_login(Plug.Conn.t(), map) :: {:ok, Plug.Conn.t()} | {:error, Plug.Conn.t()} | :error
end
