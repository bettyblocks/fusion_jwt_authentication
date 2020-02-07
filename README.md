[![Build Status](https://travis-ci.org/nulian/fusion_jwt_authentication.svg?branch=master)](https://travis-ci.org/nulian/fusion_jwt_authentication)

# FusionJwtAuthentication

Library to authenticate jwt token with a plug.

Below can be configured in your app.
`error_view` you can change to your phoenix error view though it needs the options 401.json and 404.json

`claim_options`  Follow the joker claims though you will probably need to set the iss and aud in a keyword list. `iss` is the jwt supplier name from the jwt.
`aud` is the application of fusionauth the jwt is used for logging in to.

`base_url` Should be the url of fusionauth like `fusionauth.test.com`

```elixir
config :fusion_jwt_authentication,
  http_client: HTTPoison,
  claim_options: [],
  error_view: FusionJWTAuthentication.ErrorView,
  base_url: ""
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fusion_jwt_authentication` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fusion_jwt_authentication, "~> 0.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fusion_jwt_authentication](https://hexdocs.pm/fusion_jwt_authentication).

