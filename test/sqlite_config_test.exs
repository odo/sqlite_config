defmodule SqliteConfigTest do
  use ExUnit.Case
  doctest SqliteConfig
  use ExUnit.Case, async: false

  alias SqliteConfig.Repo

  setup do
    :ok = Supervisor.terminate_child(SqliteConfig.Supervisor, Repo)
    {:ok, _} = Supervisor.restart_child(SqliteConfig.Supervisor, Repo)
    :ok
  end

  test "starts with an empty db" do
    assert_tables([])
  end

  test "accepts new schema" do
    :ok = SqliteConfig.stage_and_deploy(
      "create table foo (bar int)",
      fn(repo) ->
        {:ok, _} = repo.query("insert into foo values (1)")
      end
    )
    assert_tables(["foo"])
    # we make sure that the inserts from staging_fun
    # don't end up in the main Repo
    assert {:ok, %Exqlite.Result{rows: []}} = Repo.query("select * from foo")
    assert {:error, %Exqlite.Error{message: "attempt to write a readonly database"}} = Repo.query("insert into foo values (1)")
  end
  
  test "accepts new multiline schema" do
    dump =
    """
    create table foo (bar int);
    create table bar (foo int);
    insert into foo values (1);
    insert into bar values (2);
    """
    assert :ok == SqliteConfig.stage_and_deploy(
      dump,
      fn(repo) ->
        {:ok, %Exqlite.Result{rows: [[1]]}} = repo.query("select * from foo")
        {:ok, %Exqlite.Result{rows: [[2]]}} = repo.query("select * from bar")
      end
    )
    assert_tables(["foo", "bar"])
  end

  test "rejects bad schema" do
    assert {:error, _} = SqliteConfig.stage_and_deploy(
      "create that beautiful table foo (bar int)",
      fn(_repo) ->
        :ok
      end
    )
    assert_tables([])
  end

  test "rejects failing stage function" do
    assert {:error, _} = SqliteConfig.stage_and_deploy(
      "create table foo (bar int)",
      fn(_repo) ->
        :error
      end
    )
    assert_tables([])
  end

  test "rejects crashing stage function" do
    assert {:error, _} = SqliteConfig.stage_and_deploy(
      "create table foo (bar int)",
      fn(repo) ->
        :foo = repo
      end
    )
    assert_tables([])
  end

  defp assert_tables([]) do
    assert {:ok, %Exqlite.Result{rows: []}} = Repo.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
  end
  defp assert_tables(tables) do
    tables = tables |> Enum.map(&[&1])
    assert {:ok, %Exqlite.Result{rows: ^tables}} = Repo.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
  end
end
