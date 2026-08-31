defmodule SqliteConfig do

  alias SqliteConfig.{StageRepo, Repo}

  def stage_and_deploy(schema_sql, staging_fun) do
    with {:ok, _pid} <- reset_repo(StageRepo),
         {:ok, _} <- StageRepo.query(schema_sql),
          :ok <- execute_staging_fun(staging_fun),
         {:ok, _pid } <- reset_repo(Repo),    
         {:ok, _} <- Repo.query(schema_sql),
         {:ok, _} <- Repo.query("PRAGMA query_only = ON") do
      :ok
    end
  end

  defp execute_staging_fun(staging_fun) do
    case staging_fun.(StageRepo) do
      :ok -> :ok
      {:ok, _} -> :ok
      :error -> {:error, :staging_fun_failed}
      {:error, error} -> {:error, error}
      unknown -> {:error, unknown}
    end
  rescue
    error -> {:error, error}
  end

  defp reset_repo(repo) do
    Supervisor.terminate_child(SqliteConfig.Supervisor, repo)
    Supervisor.restart_child(SqliteConfig.Supervisor, repo)
  end
end
