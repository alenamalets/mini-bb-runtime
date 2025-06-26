defmodule DataCompiler do
  @moduledoc """
  Entry point for compiling schema and storing it in Redis.
  """
  alias DataCompiler.{Redis, Compiler}

  @max_retries 5
  @retry_delay 1000

  def run do
    connect_and_compile(@max_retries)
  end

  defp connect_and_compile(0) do
    IO.puts("❌ Failed to connect to Redis after several attempts.")
  end

  defp connect_and_compile(attempts_left) do
    case Redis.start_link() do
      {:ok, _pid} ->
        schema = %{
          "table" => "users",
          "columns" => ["id", "name", "email"]
        }

        Compiler.compile(schema)
        IO.puts("✅ Compiled and stored schema in Redis")

      {:error, _reason} ->
        IO.puts("⏳ Redis not ready, retrying in #{@retry_delay}ms...")
        Process.sleep(@retry_delay)
        connect_and_compile(attempts_left - 1)
    end
  end
end
