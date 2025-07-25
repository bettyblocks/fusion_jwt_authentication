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

    Supervisor.start_link(
      [{Finch, name: FusionJWTAuthentication.MyFinch, pools: %{default: finch_config()}}] ++ children,
      strategy: :one_for_one
    )
  end

  defp finch_config do
    case Application.get_env(:fusion_jwt_authentication, :custom_ca_cert) do
      cert when is_binary(cert) and byte_size(cert) > 0 ->
        [
          conn_opts: [
            transport_opts: [
              cacertfile: cert
            ]
          ]
        ]

      _ ->
        []
    end
  end
end
