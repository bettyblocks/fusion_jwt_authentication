defmodule FusionJWTAuthentication.FusionJWTAuthPlugTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  alias FusionJWTAuthentication.FusionJWTAuthPlug
  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate
  alias FusionJWTAuthentication.TokenCertificateStore
  alias FusionJWTAuthentication.TokenJWKS
  alias FusionJWTAuthentication.Support.TestUtils
  alias FusionJWTAuthentication.JWKS_Strategy
  alias Joken.Signer

  import Mox
  import Tesla.Mock, only: [json: 1]

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    {:ok, cas_token: "1111111111111111111111111111111111111"}
  end

  test "Exp key cannot be expired in the jwt token", %{cas_token: cas_token} do
    claims = %{
      "cas_token" => cas_token,
      "exp" => Joken.current_time() - 100,
      "aud" => "11111111-1111-1111-1111-111111111111"
    }

    signer = Signer.create("RS256", FusionGlobalAppCertificate.private_key())
    jwt = TokenCertificateStore.generate_and_sign!(claims, signer)

    %{status: status, halted: halted} =
      :get
      |> conn("/")
      |> put_req_cookie("jwt_token", "#{jwt}")
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

    assert status == 401
    assert halted
  end

  test "sets cas token when claims contains a cas_token", %{cas_token: cas_token} do
    claims = %{
      "cas_token" => cas_token,
      "exp" => Joken.current_time() + 120,
      "aud" => "11111111-1111-1111-1111-111111111111"
    }

    signer = Signer.create("RS256", FusionGlobalAppCertificate.private_key())
    jwt = TokenCertificateStore.generate_and_sign!(claims, signer)

    conn =
      :get
      |> conn("/")
      |> put_req_cookie("jwt_token", jwt)
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

    assert conn.status == nil
    refute conn.halted
    assert Map.get(conn.assigns, :cas_token) == cas_token
  end

  test "does not set cas token when claims contain no cas_token" do
    claims = %{
      "exp" => Joken.current_time() + 120,
      "aud" => "11111111-1111-1111-1111-111111111111"
    }

    signer = Signer.create("RS256", FusionGlobalAppCertificate.private_key())
    jwt = TokenCertificateStore.generate_and_sign!(claims, signer)

    conn =
      :get
      |> conn("/")
      |> put_req_cookie("jwt_token", jwt)
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

    assert conn.status == nil
    refute conn.halted
    refute Map.has_key?(conn.assigns, :cas_token)
  end

  test "should return not found when certificate is not found" do
    on_exit(fn ->
      Application.put_env(:fusion_jwt_authentication, :claim_options,
        iss: "bettyblocks.com",
        aud: "11111111-1111-1111-1111-111111111111"
      )
    end)

    claims = %{
      "exp" => Joken.current_time() + 120,
      "aud" => "11111111-1111-1111-1111-111111111112"
    }

    Application.put_env(:fusion_jwt_authentication, :claim_options,
      iss: "bettyblocks.com",
      aud: "11111111-1111-1111-1111-111111111112"
    )

    signer = Signer.create("RS256", FusionGlobalAppCertificate.private_key())
    jwt = TokenCertificateStore.generate_and_sign!(claims, signer)

    conn =
      :get
      |> conn("/")
      |> put_req_cookie("jwt_token", jwt)
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

    assert conn.status == 404
    assert conn.halted
    refute Map.has_key?(conn.assigns, :cas_token)
  end

  test "forbids connections without an \"authorization\" header" do
    %{status: status, halted: halted} =
      :get
      |> conn("/")
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

    assert status == 401
    assert halted
  end

  describe "fusion jwt auth plug using JWKS endpoint" do
    setup do
      Application.put_env(:fusion_jwt_authentication, :token_verifier, TokenJWKS)
      Supervisor.start_link([JWKS_Strategy], strategy: :one_for_one)

      on_exit(fn ->
        Application.delete_env(:fusion_jwt_authentication, :token_verifier)
      end)
    end

    test "validate token using jwks and set the cas token", %{cas_token: cas_token} do
      claims = %{
        "cas_token" => cas_token,
        "exp" => Joken.current_time() + 120,
        "aud" => "11111111-1111-1111-1111-111111111111"
      }

      setup_jwks()
      jwt = TokenJWKS.generate_and_sign!(claims, TestUtils.create_signer_with_kid("id2"))

      conn =
        :get
        |> conn("/")
        |> put_req_cookie("jwt_token", jwt)
        |> fetch_cookies()
        |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

      assert conn.status == nil
      refute conn.halted
      assert Map.get(conn.assigns, :cas_token) == cas_token
    end

    test "if kid does not match, returns 401", %{cas_token: cas_token} do
      claims = %{
        "cas_token" => cas_token,
        "exp" => Joken.current_time() + 120,
        "aud" => "11111111-1111-1111-1111-111111111111"
      }

      setup_jwks()
      jwt = TokenJWKS.generate_and_sign!(claims, TestUtils.create_signer_with_kid("id4"))

      conn =
        :get
        |> conn("/")
        |> put_req_cookie("jwt_token", jwt)
        |> fetch_cookies()
        |> FusionJWTAuthPlug.call(FusionJWTAuthPlug.init())

      assert conn.status == 401
      assert conn.halted
    end
  end

  def setup_jwks() do
    url = "https://fusionauth.test.well-known/jwks.json"

    expect_call(fn %{url: ^url} ->
      {:ok, json(%{"keys" => [TestUtils.build_key("id1"), TestUtils.build_key("id2")]})}
    end)

    JWKS_Strategy.fetch_signers(url, log_level: :debug)
  end

  defp expect_call(num_of_invocations \\ 1, function),
    do: expect(TeslaAdapterMock, :call, num_of_invocations, fn env, _opts -> function.(env) end)
end
