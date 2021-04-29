defmodule FusionJWTAuthentication do
  @moduledoc """
  Documentation for FusionJwtAuthentication.
  """
  use Application

  alias FusionJWTAuthentication.CertificateStore
  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.TokenJWKS

  def start(_type, _args) do
    token_verifier = Application.get_env(:fusion_jwt_authentication, :token_verifier)

    children =
      if token_verifier == TokenJWKS do
        [JWKS_Strategy]
      else
        [CertificateStore]
      end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
