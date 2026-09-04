import Config

config :sqlite_config,
  ecto_repos: [SqliteConfig.Repo, SqliteConfig.StageRepo]

config :sqlite_config, SqliteConfig.Repo,
  pool_size: 1,
  database: :memory

config :sqlite_config, SqliteConfig.StageRepo,
  pool_size: 1,
  database: :memory
