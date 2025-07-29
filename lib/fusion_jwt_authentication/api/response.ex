defmodule FusionJWTAuthentication.API.Response do
  @moduledoc false

  @spec handle_response(Tesla.Env.result()) ::
          {:ok, {non_neg_integer, map}} | {:error, Tesla.Env.t() | non_neg_integer}
  def handle_response({:ok, %Tesla.Env{status: status_code, body: results}}) when status_code < 300 do
    {:ok, {status_code, results}}
  end

  def handle_response({:ok, %Tesla.Env{} = response}) do
    {:error, response}
  end

  def handle_response(error), do: error
end
