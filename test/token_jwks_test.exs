defmodule FusionJWTAuthentication.TokenJWKSTest do
  use ExUnit.Case, async: false
  alias FusionJWTAuthentication.TokenJWKS
  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.Support.TestUtils

  test "module exists" do
    assert is_list(TokenJWKS.module_info())
  end

  test "can fetch jwks and verify token" do
    JWKS_Strategy.start_link([])

    jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

    assert {:ok, claims} = TokenJWKS.verify(jwt)

    assert %{
             "aud" => "11111111-1111-1111-1111-111111111111",
             "iss" => "bettyblocks.com"
           } = claims
  end
end
