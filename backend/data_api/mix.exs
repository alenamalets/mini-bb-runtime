defmodule DataApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_api,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DataApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.14"},
      {:jason, "~> 1.0"},
      {:redix, "~> 1.1"}
    ]
  end
end
