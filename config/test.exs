use Mix.Config

config :fusion_jwt_authentication,
  http_client: Synapse.HTTPFusionMock,
  claim_options: [iss: "bettyblocks.com", aud: "11111111-1111-1111-1111-111111111111"]

config :logger, level: :warn
