defmodule Synapse.HTTPFusionMock do
  @moduledoc """
  Mock client for calls to fusionauth
  """
  alias HTTPoison.Response
  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate

  def get("/api/jwt/public-key?applicationId=11111111-1111-1111-1111-111111111111") do
    public_key = %{"publicKey" => FusionGlobalAppCertificate.public_key()["pem"]}
    {:ok, %Response{body: Jason.encode!(public_key), status_code: 200}}
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
end
