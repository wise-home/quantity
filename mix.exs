defmodule Quantity.MixProject do
  use Mix.Project

  def project do
    [
      app: :quantity,
      version: "0.3.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Hex
      description: "An Elixir data structure that encapsulates a decimal value with a unit",
      package: package(),

      # Docs
      name: "Quantity",
      source_url: "https://github.com/wise-home/quantity",
      homepage_url: "https://github.com/wise-home/quantity",
      docs: docs()
    ]
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
      # Decimal
      {:decimal, "~> 1.0"},

      # Documentation
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},

      # Static code analysis
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ~w[lib test/support]
  defp elixirc_paths(_), do: ~w[lib]

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit]
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/wise-home/quantity"}
    ]
  end
end
