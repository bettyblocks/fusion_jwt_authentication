defmodule FusionJWTAuthentication.FusionJWTAuthPlugTest do
  use ExUnit.Case
  use Phoenix.ConnTest

  alias FusionJWTAuthentication.FusionJWTAuthPlug
  alias FusionJWTAuthentication.Token
  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate
  alias Joken.Signer

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
    jwt = Token.generate_and_sign!(claims, signer)

    %{status: status, halted: halted} =
      :get
      |> build_conn("/")
      |> put_req_cookie("jwt_token", "#{jwt}")
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call([])

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
    jwt = Token.generate_and_sign!(claims, signer)

    conn =
      :get
      |> build_conn("/")
      |> put_req_cookie("jwt_token", jwt)
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call([])

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
    jwt = Token.generate_and_sign!(claims, signer)

    conn =
      :get
      |> build_conn("/")
      |> put_req_cookie("jwt_token", jwt)
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call([])

    assert conn.status == nil
    refute conn.halted
    refute Map.has_key?(conn.assigns, :cas_token)
  end

  test "forbids connections without an \"authorization\" header" do
    %{status: status, halted: halted} =
      :get
      |> build_conn("/")
      |> fetch_cookies()
      |> FusionJWTAuthPlug.call([])

    assert status == 401
    assert halted
  end
end
