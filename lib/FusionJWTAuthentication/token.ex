defmodule FusionJWTAuthentication.Token do
  @moduledoc false
  use Joken.Config

  @impl true
  def token_config do
    default_claims(Application.get_env(:fusion_jwt_authentication, :claim_options))
  end
end
