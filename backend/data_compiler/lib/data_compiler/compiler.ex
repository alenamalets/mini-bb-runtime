defmodule DataCompiler.Compiler do
  @moduledoc """
  Compiles a given schema into a structured format and stores it in Redis.
  """

  alias DataCompiler.Redis

  def compile(schema) do
    table = schema["table"]
    columns = schema["columns"]

    compiled = %{
      table: table,
      columns: columns,
      endpoints: [
        %{
          method: "GET",
          path: "/#{table}",
          query: "SELECT * FROM #{table}"
        },
        %{
          method: "GET",
          path: "/#{table}/:id",
          query: "SELECT * FROM #{table} WHERE id = $1"
        }
      ]
    }

    Redis.set("compiled_schema:#{table}", compiled)
  end
end
