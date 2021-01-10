defmodule OsmShortlink.MixProject do
  use Mix.Project

  def project do
    [
      app: :osm_shortlink,
      version: "0.1.2",
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
    """
    Library that generates short links for the given coordinates

        iex> OsmShortlink.generate_link(51.5110,0.0550, 9)
        "http://osm.org/go/0EEQjE--"
        iex> OsmShortlink.link_to_coordinates("http://osm.org/go/0EEQjE?M")
        {51.510772705078125, 0.054931640625}

    """
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
