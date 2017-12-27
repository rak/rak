defmodule Rak.Mixfile do
  use Mix.Project

  def application, do: [
    extra_applications: extra_applications(Mix.env)
  ]

  def project, do: [
    app: :rak,
    name: "Rak",
    description: "Game Server Maker",
    version: "0.1.2",
    elixir: "~> 1.5",
    start_permanent: Mix.env == :prod,
    deps: deps(),
    package: package(),
    docs: [
      main: "userguide",
      logo: "./images/logo_icon_light.png",
      extras: ["UserGuide.md", "Contributing.md", "License.md"]
    ],
    test_coverage: [tool: Coverex.Task, coveralls: true]
  ]

  defp package, do: [
    name: "rak",
    homepage_url: "https://rak.github.io",
    source_url: "https://github.com/rak/rak",
    maintainers: [
      "https://github.com/stelcheck"
    ],
    files: [
      "lib",
      "config",
      "mix.exs",
      "*.md",
    ],
    licenses: [
      "MIT"
    ],
    links: %{
      "GitHub" => "https://github.com/rak/rak"
    }
  ]

  defp extra_applications(:dev),     do: [:reprise] ++ extra_applications(nil)
  defp extra_applications(_default), do: [:logger]

  # Run "mix help deps" to learn about dependencies.
  defp deps, do: [
    {:reprise, "~> 0.5", only: :dev},
    {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.18", only: :dev, runtime: false},
    {:coverex, "~> 1.4.15", only: :test},
  ]
end
