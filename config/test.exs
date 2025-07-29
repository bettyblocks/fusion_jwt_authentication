import Config

config :fusion_jwt_authentication,
  http_client: FusionJWTAuthentication.Support.HTTPFusionMock,
  claim_options: [iss: "bettyblocks.com", aud: "11111111-1111-1111-1111-111111111111"],
  base_url: "http://auth.betty.docker"

config :logger, level: :warning
