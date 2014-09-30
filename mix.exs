defmodule Et.Mixfile do
  use Mix.Project

  def project do
    [app: :et,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     escript: escript,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp escript do
    [
      main_module: Ethanol
    ]
  end

  defp deps do
    []
  end
end
