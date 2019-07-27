defmodule Exavier.MixProject do
  use Mix.Project

  def project do
    [
      app: :exavier,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Elixir mutation testing library"
  end

  defp deps, do: []

  defp package do
    [
      maintainers: ["Daniel Serrano"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/dnlserrano/exavier",
        personal: "https://dnlserrano.dev",
      },
    ]
  end
end
