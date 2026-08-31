defmodule SqliteConfig.Repo do
  use Ecto.Repo, otp_app: :sqlite_config, adapter: Ecto.Adapters.SQLite3
end
