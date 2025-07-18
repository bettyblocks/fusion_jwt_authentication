defmodule FusionJWTAuthentication.API.JWT do
  @moduledoc """
  Handles api request to FusionAuth jwt endpoints
  """
  alias FusionJWTAuthentication.API.Response
  alias FusionJWTAuthentication.Utils.HTTPClient

  @typedoc """
  A hex-encoded UUID string.
  """
  @type uuid :: <<_::288>>

  @spec jwks :: {:ok, any} | {:error, any}
  def jwks do
    HTTPClient.client()
    |> Tesla.get("/.well-known/jwks.json")
    |> Response.handle_response()
  end

  @spec public_key(uuid) :: nil | String.t()
  def public_key(client_id) do
    case request_public_key(client_id) do
      {:ok, {_, %{"publicKey" => key}}} -> key
      _ -> nil
    end
  end

  defp request_public_key(client_id) do
    HTTPClient.client()
    |> Tesla.get("/api/jwt/public-key?applicationId=#{client_id}")
    |> Response.handle_response()
  end
end
