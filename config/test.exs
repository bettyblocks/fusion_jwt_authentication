use Mix.Config

config :fusion_jwt_authentication,
  http_client: Synapse.HTTPFusionMock,
  claim_options: [iss: "bettyblocks.com"]

config :logger, level: :warn
