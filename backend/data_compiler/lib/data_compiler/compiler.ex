defmodule DataCompiler.Compiler do
  @moduledoc """
  Compiles a schema and stores it in Redis.
  """

  alias DataCompiler.Redis
  require Logger

  @schemas_dir "schemas"

  def compile_all_schemas do
    case File.ls(@schemas_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".json"))
        |> Enum.each(fn file ->
          path = Path.join(@schemas_dir, file)

          case File.read(path) do
            {:ok, content} ->
              schema = Jason.decode!(content)
              compile(schema)
              Logger.info("✅ Compiled #{file} and stored in Redis.")

            {:error, reason} ->
              Logger.error("❌ Failed to read #{file}: #{inspect(reason)}")
          end
        end)

        :ok

      {:error, reason} ->
        Logger.error("❌ Failed to list schemas directory: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def compile(%{"table" => table_name} = schema) when is_binary(table_name) do
    try do
      key = "compiled_schema:#{table_name}"
      Redis.set(key, schema)
      Logger.info("✅ Compiled and stored schema for table '#{table_name}' in Redis.")
      :ok
    rescue
      error ->
        Logger.error("❌ Failed to store schema: #{inspect(error)}")
        {:error, error}
    end
  end

  def compile(_invalid_schema) do
    Logger.error("❌ Invalid schema format. Expected a map with a 'table' key.")
    {:error, :invalid_schema}
  end
end
