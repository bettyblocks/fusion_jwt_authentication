defmodule FusionJWTAuthentication.TokenCertificateStore do
  @moduledoc false
  use Joken.Config

  alias FusionJWTAuthentication.CertificateStore
  alias Joken.Signer

  @impl true
  def token_config do
    default_claims(Application.get_env(:fusion_jwt_authentication, :claim_options))
  end

  def verify_token(jwt) do
    with {:ok, %{"alg" => "RS256"}} <- Joken.peek_header(jwt),
         {:ok, claims} <- Joken.peek_claims(jwt),
         {:ok, %{"aud" => audience}} <- validate(claims),
         certificate when is_binary(certificate) <- CertificateStore.get_certificate(audience) do
      verify(jwt, Signer.create("RS256", %{"pem" => certificate}))
    end
  end
end
