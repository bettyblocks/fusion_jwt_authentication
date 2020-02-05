defmodule FusionJWTAuthentication.MixProject do
  use Mix.Project

  def project do
    [
      app: :fusion_jwt_authentication,
      version: "0.1.1",
      elixir: "~> 1.9",
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      package: package(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp description do
    "Plug for verifying fusionauth certificate signed jwt tokens"
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "LICENSE"],
      maintainers: ["Peter Arentsen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bettyblocks/fusion_jwt_authentication"}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :jason],
      mod: {FusionJWTAuthentication, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:joken, "~> 2.0"},
      {:phoenix, ">= 1.3.0"},
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:credo, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.12", only: :test},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
