defmodule FusionJWTAuthentication do
  @moduledoc """
  Documentation for FusionJwtAuthentication.
  """
  use Application

  alias FusionJWTAuthentication.CertificateStore
  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.TokenCertificateStore

  def start(_type, _args) do
    token_verifier = Application.get_env(:fusion_jwt_authentication, :token_verifier)

    children =
      if token_verifier == TokenCertificateStore do
        [CertificateStore]
      else
        [JWKS_Strategy]
      end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
