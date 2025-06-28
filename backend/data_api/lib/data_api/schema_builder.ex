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
end
