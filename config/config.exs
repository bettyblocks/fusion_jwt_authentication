use Mix.Config

config :fusion_jwt_authentication,
  http_client: HTTPoison,
  claim_options: [],
  error_view: FusionJWTAuthentication.ErrorView,
  base_url: ""

import_config "#{Mix.env()}.exs"
