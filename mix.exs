defmodule Ecto.Rescope.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :ecto_rescope,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Hex
      description: "Extends Ecto to allow rescoping of the default schema query",
      package: package(),

      # Docs
      name: "Ecto.Rescope",
      docs: docs(),

      # Code Quality
      preferred_cli_env: [
        test: :test,
        "ecto.gen.migration": :test,
        "ecto.create": :test,
        "ecto.drop": :test,
        "ecto.migrate": :test,
        "ecto.reset": :test,
        "ecto.rollback": :test,
        "ecto.setup": :test
      ],
      dialyzer: [plt_add_apps: [:mix], ignore_warnings: "dialyzer.ignore_warnings"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  ## PRIVATE FUNCTIONS

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0", only: [:dev, :test]},
      {:postgrex, ">= 0.0.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "Ecto.Rescope",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ecto_rescope",
      extra_section: "GUIDES",
      source_url: "https://github.com/erikreedstrom/ecto_rescope",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules()
    ]
  end

  def extras() do
    ["README.md"]
  end

  defp groups_for_extras do
    []
  end

  defp groups_for_modules do
    []
  end

  defp package do
    [
      maintainers: ["Erik Reedstrom"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/erikreedstrom/ecto_rescope"},
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end
end
