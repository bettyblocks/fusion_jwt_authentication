defmodule FusionJWTAuthentication.TokenJWKSTest do
  use ExUnit.Case, async: false
  alias FusionJWTAuthentication.TokenJWKS
  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.Support.TestUtils

  describe "test JWKS token" do
    setup do
      JWKS_Strategy.start_link([])
      :ok
    end

    test "module exists" do
      assert is_list(TokenJWKS.module_info())
    end

    test "can fetch jwks and verify token" do
      jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

      assert {:ok, claims} = TokenJWKS.verify(jwt)

      assert %{
               "aud" => "11111111-1111-1111-1111-111111111111",
               "iss" => "bettyblocks.com"
             } = claims
    end

    test "if jwks signers does not exist in ets cache it does a refetch" do
      :ets.delete(FusionJWTAuthentication.JWKS_Strategy.EtsCache, :signers)

      jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

      assert {:ok, claims} = TokenJWKS.verify(jwt)

      assert %{
               "aud" => "11111111-1111-1111-1111-111111111111",
               "iss" => "bettyblocks.com"
             } = claims
    end

    test "it returns kid to not match when an invalid kid is supplied" do
      jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id4"))

      assert {:error, :kid_does_not_match} = TokenJWKS.verify(jwt)
    end
  end
end
