defmodule FusionJWTAuthentication.Support.HTTPFusionMock do
  @moduledoc """
  Mock client for calls to fusionauth
  """
  @behaviour Tesla.Adapter

  alias FusionJWTAuthentication.Support.FusionGlobalAppCertificate
  alias FusionJWTAuthentication.Support.TestUtils

  @impl true
  def call(
        %Tesla.Env{
          method: :get,
          url: "http://auth.betty.docker/api/jwt/public-key?applicationId=11111111-1111-1111-1111-111111111111"
        },
        _
      ) do
    public_key = %{"publicKey" => FusionGlobalAppCertificate.public_key()["pem"]}
    {:ok, %Tesla.Env{body: public_key, status: 200}}
  end

  def call(
        %Tesla.Env{
          method: :get,
          url: "http://auth.betty.docker/api/jwt/public-key?applicationId=11111111-1111-1111-1111-111111111112"
        },
        _
      ) do
    {:ok, %Tesla.Env{body: %{}, status: 404}}
  end

  def call(%Tesla.Env{method: :get, url: "http://auth.betty.docker/api/jwt/public-key?applicationId=time"}, _) do
    {:ok,
     %Tesla.Env{
       body: %{"publicKey" => inspect(DateTime.now("Etc/UTC"))},
       status: 200
     }}
  end

  def call(%Tesla.Env{method: :get, url: "http://auth.betty.docker/api/jwt/" <> _url}, _) do
    {:ok, %Tesla.Env{body: "incorrect", status: 404}}
  end

  def call(%Tesla.Env{method: :get, url: "http://auth.betty.docker/.well-known/jwks.json"}, _) do
    {:ok,
     %Tesla.Env{
       body: %{"keys" => [TestUtils.build_key("id1"), TestUtils.build_key("id2")]},
       status: 200
     }}
  end

  def call(%Tesla.Env{method: :post, url: "http://auth.betty.docker/api/passwordless/start", body: body}, _) do
    case Jason.decode!(body) do
      %{"state" => %{"status" => status}} ->
        {:ok, %Tesla.Env{status: status}}

      _ ->
        {:ok, %Tesla.Env{body: %{"code" => "CynAUMCHLxCCAWyHXOVWPQd8ZY0a6U0e3YpYkT0MNxs"}, status: 200}}
    end
  end

  def call(%Tesla.Env{method: :post, url: "http://auth.betty.docker/api/passwordless/login", body: body}, _) do
    case Jason.decode!(body) do
      %{"code" => "logincodesuccess"} ->
        {:ok,
         %Tesla.Env{
           body: %{"token" => "token", "refreshToken" => "refreshToken", "state" => %{"prompt" => "prompt"}},
           status: 200
         }}

      %{"code" => "invalid"} ->
        {:ok, %Tesla.Env{status: 400}}

      %{"code" => "not_found"} ->
        {:ok, %Tesla.Env{status: 404}}

      _ ->
        {:error, :invalid}
    end
  end

  def call(_, _) do
    {:error, :not_implemented}
  end
end
