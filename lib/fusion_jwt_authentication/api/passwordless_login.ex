defmodule FusionJWTAuthentication.API.PasswordlessLogin do
  @moduledoc false

  alias FusionJWTAuthentication.API.Response
  alias FusionJWTAuthentication.Utils.HTTPClient

  def start(application_id, login_id, state) do
    true
    |> HTTPClient.client()
    |> Tesla.post("/api/passwordless/start", %{
      "applicationId" => application_id,
      "loginId" => login_id,
      "state" => state
    })
    |> Response.handle_response()
  end

  def login(code, application_id) do
    HTTPClient.client()
    |> Tesla.post("/api/passwordless/login", %{"code" => code, "applicationId" => application_id})
    |> Response.handle_response()
  end
end
