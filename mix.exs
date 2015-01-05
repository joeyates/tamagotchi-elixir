defmodule Tamagotchi.Mixfile do
  use Mix.Project

  def project do
    [app: :tamagotchi,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps,
     escript: escript]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp escript do
    [main_module: Game, embeded_elixir: true]
  end
end
