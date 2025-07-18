defmodule FusionJWTAuthentication.MixProject do
  use Mix.Project

  def project do
    [
      app: :fusion_jwt_authentication,
      version: "2.0.0",
      elixir: "~> 1.14",
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
  defp elixirc_paths(:test), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

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
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
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
      {:credo, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 1.4.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12", only: :test},
      {:finch, "~> 0.20"},
      {:jason, "~> 1.0"},
      {:joken, "~> 2.0"},
      {:plug, "~> 1.11"},
      {:styler, "~> 1.5", only: [:dev, :test], runtime: false},
      {:tesla, "~> 1.14"}
    ]
  end
end
