defmodule Exavier.MixProject do
  use Mix.Project

  def project do
    [
      app: :exavier,
      version: "0.1.4",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      env: [test_file_to_module_func: [Exavier, :test_file_to_module_func]]
    ]
  end

  defp description do
    "Elixir mutation testing library"
  end

  defp deps, do: []

  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_), do: ["lib"]

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
