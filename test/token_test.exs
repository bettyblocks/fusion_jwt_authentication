defmodule FusionJWTAuthentication.TokenTest do
  use ExUnit.Case, async: false

  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.Support.TestUtils
  alias FusionJWTAuthentication.Token

  describe "test JWKS token" do
    setup do
      JWKS_Strategy.start_link([])
      :ok
    end

    test "module exists" do
      assert is_list(Token.module_info())
    end

    test "can fetch jwks and verify token" do
      jwt = Token.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

      assert {:ok, claims} = Token.verify(jwt)

      assert %{
               "aud" => "11111111-1111-1111-1111-111111111111",
               "iss" => "bettyblocks.com"
             } = claims
    end

    test "it returns kid to not match when an invalid kid is supplied" do
      jwt = Token.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id4"))

      assert {:error, :kid_does_not_match} = Token.verify(jwt)
    end
  end
end
