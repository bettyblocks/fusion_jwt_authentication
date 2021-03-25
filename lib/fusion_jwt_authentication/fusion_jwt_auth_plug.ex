defmodule FusionJWTAuthentication.FusionJWTAuthPlug do
  @moduledoc """
  This plug handles JWT from fusion auth
  """
  @behaviour Plug

  alias FusionJWTAuthentication.{CertificateStore, Token}
  alias Joken.Signer
  alias Plug.Conn

  @impl true
  def init(options \\ []) do
    login_handler =
      Application.get_env(:fusion_jwt_authentication, :login_handler, FusionJWTAuthentication.DefaultHandleLogin)

    Keyword.put(options, :login_handler, login_handler)
  end

  @impl true
  def call(conn, options) do
    parse_jwt(conn.cookies["jwt_token"], conn, options)
  end

  defp parse_jwt(jwt, conn, opts) when is_binary(jwt) do
    login_handler = Keyword.get(opts, :login_handler)

    with {:ok, %{"alg" => "RS256"}} <- Joken.peek_header(jwt),
         {:ok, claims} <- Joken.peek_claims(jwt),
         {:ok, %{"aud" => audience}} <- Token.validate(claims),
         certificate when is_binary(certificate) <- CertificateStore.get_certificate(audience),
         {:ok, claims} <- Token.verify(jwt, Signer.create("RS256", %{"pem" => certificate})),
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
