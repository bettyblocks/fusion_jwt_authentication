defmodule FusionJwtAuthentication.MixProject do
  use Mix.Project

  def project do
    [
      app: :fusion_jwt_authentication,
      version: "0.1.0",
      elixir: "~> 1.9",
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env()),
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
      deps: deps()
    ]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support", "integration_test"]

  defp description do
    "RabbitMQ-backed background job processing system"
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "docs/*.md", "LICENSE"],
      maintainers: ["Peter Arentsen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bettyblocks/fusion_jwt_authentication"}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:json_web_token, ">= 0.0.0"},
      {:credo, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.12", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
