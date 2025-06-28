defmodule DataCompiler do
  @moduledoc """
  Entry point for compiling schema and storing it in Redis.
  """
  alias DataCompiler.{Redis, Compiler}

  @max_retries 5
  @retry_delay 1000
  @schema_dir "schemas"

  def run do
    connect_and_compile(@max_retries)
  end

  defp connect_and_compile(0) do
    IO.puts("❌ Failed to connect to Redis after several attempts.")
  end

  defp connect_and_compile(attempts_left) do
    case Redis.start_link() do
      {:ok, _pid} ->
        compile_all_schemas()

      {:error, _reason} ->
        IO.puts("⏳ Redis not ready, retrying in #{@retry_delay}ms...")
        Process.sleep(@retry_delay)
        connect_and_compile(attempts_left - 1)
    end
  end

  defp compile_all_schemas do
    @schema_dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".json"))
    |> Enum.each(&compile_schema_file/1)

    IO.puts("✅ All schemas compiled and stored in Redis")
  end

  defp compile_schema_file(filename) do
    path = Path.join(@schema_dir, filename)

    case File.read(path) do
      {:ok, content} ->
        schema = Jason.decode!(content)
        Compiler.compile(schema)
        IO.puts("✅ Compiled schema: #{schema["table"]}")

      {:error, reason} ->
        IO.puts("❌ Failed to read #{filename}: #{inspect(reason)}")
    end
  end
end
