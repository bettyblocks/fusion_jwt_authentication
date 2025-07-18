defmodule FusionJWTAuthentication.Utils.HTTPClient do
  @moduledoc """
  Perform HTTP-requests to Fusionauth to fetch applications
  The requests will authenticate with an API-key that is authorized in FusionAuth to use
  the application-endpoints.
  Each request will result in an ok-message, or error or failure, and return unique error-message
  when that occurs.
  """

  @adapter Application.compile_env(:fusion_jwt_authentication, :http_client, {Tesla.Adapter.Finch, [name: MyFinch]})

  @spec client(binary | nil) :: Tesla.Client.t()
  def client(tenant_id \\ nil) do
    Tesla.client(middleware(tenant_id), @adapter)
  end

  defp middleware(tenant_id) do
    base_middleware = [
      {Tesla.Middleware.BaseUrl, Application.get_env(:fusion_jwt_authentication, :base_url)},
      Tesla.Middleware.JSON
    ]

    if tenant_id do
      base_middleware ++
        [
          {Tesla.Middleware.Headers,
           [
             {"authorization", Application.get_env(:fusion_jwt_authentication, :fusionauth_api)},
             {"X-FusionAuth-TenantId", tenant_id}
           ]}
        ]
    else
      base_middleware
    end
  end
end
