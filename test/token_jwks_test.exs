defmodule FusionJWTAuthentication.TokenJWKSTest do
  use ExUnit.Case, async: false
  alias FusionJWTAuthentication.TokenJWKS
  alias FusionJWTAuthentication.Strategy
  alias FusionJWTAuthentication.Support.TestUtils

  import Mox
  import Tesla.Mock, only: [json: 1]

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    Supervisor.start_link([Strategy], strategy: :one_for_one)
    :ok
  end

  test "module exists" do
    assert is_list(TokenJWKS.module_info())
  end

  test "can fetch jwks and verify token" do
    setup_jwks()

    jwt = TokenJWKS.generate_and_sign!(%{}, TestUtils.create_signer_with_kid("id2"))

    assert {:ok, claims} = TokenJWKS.verify(jwt)

    assert %{
             "aud" => "11111111-1111-1111-1111-111111111111",
             "iss" => "bettyblocks.com"
           } = claims
  end

  def setup_jwks() do
    url = "https://fusionauth.test.well-known/jwks.json"

    expect_call(fn %{url: ^url} ->
      {:ok, json(%{"keys" => [TestUtils.build_key("id1"), TestUtils.build_key("id2")]})}
    end)

    Strategy.fetch_signers(url, log_level: :debug)
    #  Strategy.start_link(jwks_url: url, time_interval: 10)
    :timer.sleep(100)
  end

  defp expect_call(num_of_invocations \\ 1, function),
    do: expect(TeslaAdapterMock, :call, num_of_invocations, fn env, _opts -> function.(env) end)
end
