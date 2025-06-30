defmodule DataApi.SchemaBuilder do
  alias DataApi.Repo
  require Logger

  def create(%{"table" => table_name, "columns" => columns}) do
    columns_sql =
      columns
      |> Enum.map(&"#{&1} TEXT")
      |> Enum.join(", ")

    sql = "CREATE TABLE IF NOT EXISTS #{table_name} (#{columns_sql})"

    case Ecto.Adapters.SQL.query(Repo, sql, []) do
      {:ok, _result} ->
        Logger.info("✅ Table #{table_name} created.")
        :ok

      {:error, reason} ->
        Logger.error("❌ Failed to create table: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def insert_test_data(%{"table" => table, "columns" => columns}) do
    # Prepare INSERT statement
    column_list = Enum.join(columns, ", ")
    placeholders = Enum.map(1..length(columns), fn i -> "$#{i}" end) |> Enum.join(", ")

    sql = "INSERT INTO #{table} (#{column_list}) VALUES (#{placeholders})"

    # Example data rows
    rows = [
      ["1", "Alice", "alice@example.com", "owner"],
      ["2", "Bob", "bob@example.com", "admin"],
      ["3", "Charlie", "charlie@example.com", "user"]
    ]

    Enum.each(rows, fn row ->
      Ecto.Adapters.SQL.query!(DataApi.Repo, sql, row)
    end)

    :ok
  end
end
