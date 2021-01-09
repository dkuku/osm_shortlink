defmodule OsmShortlink.MixProject do
  use Mix.Project

  def project do
    [
      app: :osm_shortlink,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
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
      {:ex_doc, "~> 0.23"}
    ]
  end

  defp description() do
    "Library that generates short links for the given coordinates"
  end

  defp package() do
    [
      source_url: "https://github.com/dkuku/osm_shortlink",
      files: ~w(lib mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/dkuku/osm_shortlink"}
    ]
  end
end
