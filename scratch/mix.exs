defmodule Quaff.Mixfile do
  use Mix.Project

  def project do
    [
      app: :quaff,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: true,
      escript: [ main_module: Quaff ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger, :cecho],
      mod: {Quaff, []},
      registered: [:quaff]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cecho, git: "https://github.com/mazenharake/cecho.git", tag: "0.5.1"}
    ]
  end
end
