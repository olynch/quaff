defmodule QuaffServer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :quaff_server,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
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
      {:cecho, git: "https://github.com/mazenharake/cecho.git", tag: "0.5.1", app: false}
    ]
  end
end
