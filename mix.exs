defmodule RIFF.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :riff,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "This is an Elixir module for reading and writing RIFF files.",
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/b123400/riff",
        },
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp docs do
    [
      extras: ["README.md", "LICENSE"],
      main: "readme",
      name: "RIFF",
      canonical: "https://hexdocs.pm/riff",
      source_ref: "v#{@version}",
      source_url: "https://github.com/b123400/riff",
      api_reference: false
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
