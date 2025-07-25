import Config

config :fusion_jwt_authentication,
  http_client: {Tesla.Adapter.Finch, [name: FusionJWTAuthentication.MyFinch]},
  claim_options: [],
  error_view: FusionJWTAuthentication.ErrorView,
  base_url: ""

config :tesla, disable_deprecated_builder_warning: true

import_config "#{Mix.env()}.exs"
