defmodule SqliteConfig.Application do
  use Application

  @impl true
  def start(_, _) do
    children = [
      SqliteConfig.Repo,
      SqliteConfig.StageRepo,
    ]
    opts = [strategy: :one_for_one, name: SqliteConfig.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
