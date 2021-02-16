defmodule FusionJWTAuthentication.FusionJWTAuthPlug do
  @moduledoc """
  This plug handles JWT from fusion auth
  """
  @behaviour Plug

  alias FusionJWTAuthentication.{CertificateStore, ErrorView, Token}
  alias Joken.Signer
  alias Phoenix.Controller
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
      {:error, :signature_error} ->
        {:ok, %{"aud" => audience}} = Joken.peek_claims(jwt)
        GenServer.call(CertificateStore, {:fetch_certificate, audience})

      {_, _claims} ->
        send_unauthorized_response(conn)

      _ ->
        send_not_found_response(conn)
    end
  end

  defp parse_jwt(_, conn, _opts), do: send_unauthorized_response(conn)

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
    Application.get_env(:fusion_jwt_authentication, :error_view) || ErrorView
  end
end
