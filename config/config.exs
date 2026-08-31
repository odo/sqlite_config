import Config

config :sqlite_config,
  ecto_repos: [SqliteConfig.Repo]

config :sqlite_config, SqliteConfig.Repo,
  pool_size: 1,
  database: :memory

