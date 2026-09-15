defmodule SqliteConfig do

  alias SqliteConfig.{StageRepo, Repo}

  @spec stage_and_deploy(String.t(), (atom() -> :ok | {:ok, any()} | {:error, any()}), Atom.t()) :: :ok | {:error, any()}
  def stage_and_deploy(schema_sql, staging_fun, target \\ Repo) do
    with {:ok, _} <- reset_repo(StageRepo, schema_sql),
          :ok     <- execute_staging_fun(staging_fun),
         {:ok, _} <- reset_repo(target, schema_sql),
         {:ok, _} <- target.query("PRAGMA query_only = ON") do
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

  defp reset_repo(repo, sql_dump) do
    repo.transact(fn ->
      remove_schema(repo)
      sql_dump
      |> String.replace("\n", "")
      |> String.split(";", trim: true)
      |> Enum.reduce_while(
        {:ok, 0},
        fn(statement, {:ok, count}) ->
          case repo.query(statement) do        
            {:ok, _} -> {:cont, {:ok, count + 1}}
            {:error, error} -> {:halt, {:error, error}}
          end
        end
      )
    end)
  rescue
    error -> {:error, error}
  end

  defp remove_schema(repo) do
    Supervisor.terminate_child(SqliteConfig.Supervisor, repo)
    Supervisor.restart_child(SqliteConfig.Supervisor, repo)
  end

end
