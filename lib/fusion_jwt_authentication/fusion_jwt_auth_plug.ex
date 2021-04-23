defmodule FusionJWTAuthentication.FusionJWTAuthPlug do
  @moduledoc """
  This plug handles JWT from fusion auth
  """
  @behaviour Plug
  alias Plug.Conn
  alias FusionJWTAuthentication.DefaultHandleLogin
  alias FusionJWTAuthentication.TokenCertificateStore

  @impl true
  def init(options \\ []) do
    login_handler =
      Application.get_env(:fusion_jwt_authentication, :login_handler, DefaultHandleLogin)

    token_verifier =
      Application.get_env(:fusion_jwt_authentication, :token_verifier, TokenCertificateStore)

    Keyword.merge(options, login_handler: login_handler, token_verifier: token_verifier)
  end

  @impl true
  def call(conn, options) do
    parse_jwt(conn.cookies["jwt_token"], conn, options)
  end

  defp parse_jwt(jwt, conn, opts) when is_binary(jwt) do
    login_handler = Keyword.get(opts, :login_handler)
    token_verifier = Keyword.get(opts, :token_verifier)

    with {:ok, claims} <- token_verifier.verify_token(jwt),
         {:ok, conn} <- login_handler.handle_login(conn, claims) do
      conn
    else
      {_, _claims} ->
        send_unauthorized_response(conn)

      _ ->
        send_not_found_response(conn)
    end
  end

  defp parse_jwt(_, conn, _opts), do: send_unauthorized_response(conn)

  defp send_unauthorized_response(conn) do
    conn
    |> put_json(401, "Access denied")
    |> Conn.halt()
  end

  defp send_not_found_response(conn) do
    conn
    |> put_json(404, "Page not found")
    |> Conn.halt()
  end

  defp put_json(conn, status, message) do
    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.send_resp(status, Jason.encode!(%{status: status, message: message}))
  end
end
