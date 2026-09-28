defmodule PigeonClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :pigeon_client,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "HTTP client and Swoosh adapter for the Pigeon email API",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/pigeonfs/pigeon-phoenix"}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:swoosh, "~> 1.16", optional: true},
      {:jason, "~> 1.4"}
    ]
  end
end
