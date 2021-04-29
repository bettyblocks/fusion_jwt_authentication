defmodule FusionJWTAuthentication.Support.HTTPFusionMock do
  @moduledoc """
  Mock client for calls to fusionauth
  """
  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate
  alias FusionJWTAuthentication.Support.TestUtils
  alias HTTPoison.Response

  def get("/api/jwt/public-key?applicationId=11111111-1111-1111-1111-111111111111") do
    public_key = %{"publicKey" => FusionGlobalAppCertificate.public_key()["pem"]}
    {:ok, %Response{body: Jason.encode!(public_key), status_code: 200}}
  end

  def get("/api/jwt/public-key?applicationId=11111111-1111-1111-1111-111111111112") do
    {:ok, %Response{body: Jason.encode!(%{}), status_code: 404}}
  end

  def get("/api/jwt/public-key?applicationId=time") do
    {:ok,
     %Response{
       body: Jason.encode!(%{"publicKey" => inspect(DateTime.now("Etc/UTC"))}),
       status_code: 200
     }}
  end

  def get("/api/jwt/" <> _url) do
    {:ok, %Response{body: "incorrect", status_code: 404}}
  end

  def get("/.well-known/jwks.json") do
    {:ok,
     %Response{
       body: Jason.encode!(%{"keys" => [TestUtils.build_key("id1"), TestUtils.build_key("id2")]}),
       status_code: 200
     }}
  end
end
