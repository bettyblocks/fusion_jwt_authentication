defmodule FusionJWTAuthentication.Strategy do
  use JokenJwks.DefaultStrategyTemplate

  def init_opts(opts) do
    base_url = Application.get_env(:fusion_jwt_authentication, :base_url)
    should_start = Mix.env() !== :test
    url = "#{base_url}/.well-known/jwks.json"

    Keyword.merge(opts, jwks_url: url, first_fetch_sync: true, should_start: should_start)
  end
end
