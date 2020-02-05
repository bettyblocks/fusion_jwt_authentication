defmodule FusionJWTAuthentication.Token do
  @moduledoc false
  use Joken.Config

  @impl true
  def token_config do
    default_claims(Keyword.put(Application.get_env(:fusion_jwt_authentication, :claim_options), :skip, [:aud]))
  end
end
