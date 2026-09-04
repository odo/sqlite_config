# SqliteConfig

This library provides a Ecto repository `SqliteConfig.Repo` where you can dynamically load configuration data during runtime. Data is assumed to be read-only.

Data is provided as SQL dumps. Each new version of the databased is first staged in a separate staging repo so it can be validated before been loaded to the main repo.

Example:
```Elixir
    dump =
    """
    create table foo (bar int);
    create table bar (foo int);
    insert into foo values (1);
    insert into bar values (2);
    """

    :ok = SqliteConfig.stage_and_deploy(
      dump,
      fn(repo) ->
        {:ok, %Exqlite.Result{rows: [[1]]}} = repo.query("select * from foo")
        {:ok, %Exqlite.Result{rows: [[2]]}} = repo.query("select * from bar")
      end
    )

    SqliteConfig.Repo.query("SELECT * FROM foo")
    > {:ok, %Exqlite.Result{command: :execute, columns: ["bar"], rows: [[1]], num_rows: 1}}
```

If the validation function crashes or returns an error, the repo is not changed:

```Elixir
    dump = ""

    SqliteConfig.stage_and_deploy(
      dump,
      fn(repo) ->
        {:ok, %Exqlite.Result{rows: [[1]]}} = repo.query("select * from foo")
        {:ok, %Exqlite.Result{rows: [[2]]}} = repo.query("select * from bar")
      end
    )
    > {:error,
        %MatchError{
          term: {:error,
           %Exqlite.Error{
             message: "no such table: foo",
             statement: "select * from foo"
           }}
        }}

    SqliteConfig.Repo.query("SELECT * FROM foo")
    > {:ok, %Exqlite.Result{command: :execute, columns: ["bar"], rows: [[1]], num_rows: 1}}
    ```
