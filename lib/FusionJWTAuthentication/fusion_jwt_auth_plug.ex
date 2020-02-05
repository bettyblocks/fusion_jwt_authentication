defmodule FusionJWTAuthentication.FusionJWTAuthPlug do
  @moduledoc """
  This plug handles JWT from fusion auth
  """

  alias FusionJWTAuthentication.{CertificateStore, Token}
  alias Joken.Signer
  alias Phoenix.Controller
  alias Plug.Conn

  def init(options), do: options

  def call(conn, options) do
    parse_jwt(conn.cookies["jwt_token"], conn, options)
  end

  defp parse_jwt(jwt, conn, _opts) when is_binary(jwt) do
    with {:ok, %{"alg" => "RS256"}} <- Joken.peek_header(jwt),
         {:ok, %{"aud" => audience}} <- Joken.peek_claims(jwt),
         certificate when is_binary(certificate) <- CertificateStore.get_certificate(audience),
         {:ok, claims} <- Token.verify_and_validate(jwt, Signer.create("RS256", %{"pem" => certificate})) do
      handle_login(conn, claims)
    else
      {_, _claims} ->
        send_unauthorized_response(conn)

      _ ->
        send_not_found_response(conn)
    end
  end

  defp parse_jwt(_, conn, _opts), do: send_unauthorized_response(conn)

  defp handle_login(conn, %{"cas_token" => cas_token}) do
    Conn.assign(conn, :cas_token, cas_token)
  end

  defp handle_login(conn, _), do: conn

  defp send_unauthorized_response(conn) do
    conn
    |> Conn.put_status(401)
    |> Controller.put_view(error_view())
    |> Controller.render("401.json")
    |> Conn.halt()
  end

  defp send_not_found_response(conn) do
    conn
    |> Conn.put_status(404)
    |> Controller.put_view(error_view())
    |> Controller.render("404.json")
    |> Conn.halt()
  end

  defp error_view do
    Application.get_env(:fusion_jwt_authentication, :error_view)
  end
end
