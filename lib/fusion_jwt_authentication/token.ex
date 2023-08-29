defmodule FusionJWTAuthentication.Token do
  @moduledoc """
  This module is used to verify the JWT token using JWKS fusionauth endpoint
  The module overides the before_verify hook in Joken package
  It is used by default as token_verifier, another module can be used by setting :token_verifier in the config.
  """
  use Joken.Config
  alias FusionJWTAuthentication.JWKS_Strategy

  @impl true
  def token_config do
    default_claims(Application.get_env(:fusion_jwt_authentication, :claim_options))
  end

  def verify_token(jwt), do: verify_and_validate(jwt)

  @impl true
  def before_verify(hook_options, {token, _signer}) do
    with strategy <- hook_options[:strategy] || JWKS_Strategy,
         {:ok, kid} <- get_token_kid(token),
         {:ok, signer} <- strategy.match_signer_for_kid(kid) do
      {:cont, {token, signer}}
    else
      err -> {:halt, err}
    end
  end

  defp get_token_kid(token) do
    with {:ok, headers} <- Joken.peek_header(token),
         {:kid, kid} when not is_nil(kid) <- {:kid, headers["kid"]} do
      {:ok, kid}
    else
      {:kid, nil} -> {:error, :no_kid_in_token_header}
      err -> err
    end
  end
end
