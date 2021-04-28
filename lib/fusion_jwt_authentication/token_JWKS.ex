defmodule FusionJWTAuthentication.TokenJWKS do
  @moduledoc false
  use Joken.Config
  alias FusionJWTAuthentication.JWKS_Strategy

  add_hook(JokenJwks, strategy: JWKS_Strategy)
  @impl true
  def token_config do
    default_claims(Application.get_env(:fusion_jwt_authentication, :claim_options))
  end

  def verify_token(jwt), do: verify(jwt)
end
