defmodule FusionJWTAuthentication.TokenJWKSTest do
  use ExUnit.Case, async: false
  alias FusionJWTAuthentication.TokenJWKS
  alias FusionJWTAuthentication.JWKS_Strategy
  alias FusionJWTAuthentication.Support.TestUtils

  import Mox
  import Tesla.Mock, only: [json: 1]

  setup :set_mox_global
  setup :verify_on_exit!

  test "module exists" do
    assert is_list(TokenJWKS.module_info())
  end

  test "can fetch jwks and verify token" do
    url = "https://fusionauth.test.well-known/jwks.json"

    expect(TeslaAdapterMock, :call, fn _, _ ->
      {:ok, json(%{"keys" => [TestUtils.build_key("id1"), TestUtils.build_key("id2")]})}
    end)

    JWKS_Strategy.start_link(jwks_url: url, log_level: :debug)

    jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

    assert {:ok, claims} = TokenJWKS.verify(jwt)

    assert %{
             "aud" => "11111111-1111-1111-1111-111111111111",
             "iss" => "bettyblocks.com"
           } = claims
  end
end
