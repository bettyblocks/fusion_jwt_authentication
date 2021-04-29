defmodule FusionJWTAuthentication.API.JWT do
  @moduledoc """
  Handles api request to FusionAuth jwt endpoints
  """
  alias HTTPoison.{Error, Response}

  @typedoc """
  A hex-encoded UUID string.
  """
  @type uuid :: <<_::288>>

  @spec jwks :: {:ok, any} | {:error, any}
  def jwks() do
    "#{base_url()}/.well-known/jwks.json"
    |> http_client().get()
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
    "#{base_url()}/api/jwt/public-key?applicationId=#{client_id}"
    |> http_client().get()
    |> handle_response()
  end

  defp base_url do
    Application.get_env(:fusion_jwt_authentication, :base_url)
  end

  defp http_client do
    Application.get_env(:fusion_jwt_authentication, :http_client) || HTTPoison
  end

  @spec handle_response({:ok, Response.t()} | {:error, Error.t()}) ::
          {:ok, {non_neg_integer, map}} | {:error, Response.t() | non_neg_integer}
  defp handle_response(resp) do
    case resp do
      {:ok, %Response{status_code: status_code, body: results}} when status_code < 300 ->
        with string when is_binary(results) <- results,
             {:ok, result_map} <- Jason.decode(string) do
          {:ok, {status_code, result_map}}
        else
          _ -> {:ok, {status_code, results}}
        end

      {:ok, %Response{} = response} ->
        {:error, response}

      error ->
        {:error, error}
    end
  end
end
