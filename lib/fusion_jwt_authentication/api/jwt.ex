defmodule FusionJWTAuthentication.API.JWT do
  @moduledoc """
  Handles api request to FusionAuth jwt endpoints
  """
  alias FusionJWTAuthentication.Utils.HTTPClient

  @typedoc """
  A hex-encoded UUID string.
  """
  @type uuid :: <<_::288>>

  @spec jwks :: {:ok, any} | {:error, any}
  def jwks do
    HTTPClient.client()
    |> Tesla.get("/.well-known/jwks.json")
    |> handle_response()
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
    |> handle_response()
  end

  @spec handle_response(Tesla.Env.result()) ::
          {:ok, {non_neg_integer, map}} | {:error, Tesla.Env.t() | non_neg_integer}
  defp handle_response({:ok, %Tesla.Env{status: status_code, body: results}}) when status_code < 300 do
    {:ok, {status_code, results}}
  end

  defp handle_response({:ok, %Tesla.Env{} = response}) do
    {:error, response}
  end

  defp handle_response(error), do: error
end
