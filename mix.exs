defmodule SqliteConfig.MixProject do
  use Mix.Project

  def project do
    [
      app: :sqlite_config,
      version: "0.1.2",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SqliteConfig.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sqlite3, "~> 0.17"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
    ]
  end
  
  defp package() do
    [
     name: "sqlite_config",
      links: %{"GitHub" => "https://github.com/odo/sqlite_config"},
     description: "Dynamic configs in a SQLite DB",
     licenses: ["MIT"],
    ]
  end
end
