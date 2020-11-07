defmodule UeberauthTwitch.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :ueberauth_twitch_strategy,
      version: @version,
      package: package(),
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/FILL_THIS_IN",
      homepage_url: "https://github.com/FILL_THIS_IN",
      description: description(),
      deps: deps(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ueberauth, :oauth2]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 2.0"},
      {:ueberauth, "~> 0.4"},

      # dev/test only dependencies
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.13", only: :test},

      # docs dependencies
      {:earmark, ">= 1.4.0", only: :dev},
      {:ex_doc, ">= 0.22.0", only: :dev}
    ]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Ueberauth strategy for using Twitch to authenticate your users."
  end

  defp package do
    [
      name: "ueberauth_twitch_strategy",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Chavez"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/CHANGE_THIS"}
    ]
  end

  defp aliases do
    [
      lint: ["format", "credo"]
    ]
  end
end
