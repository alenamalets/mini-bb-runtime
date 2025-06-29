defmodule DataCompiler.Application do
  use Application
  alias DataCompiler.Compiler

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start(_type, _args) do
    children = [
      {Redix, host: @default_host, port: @default_port, name: :redis_server}
    ]

    opts = [strategy: :one_for_one, name: DataCompiler.Supervisor]

    # Start Redis and then run the compiler once
    {:ok, pid} = Supervisor.start_link(children, opts)

    # Wait a bit for Redis to be ready, then compile
    Task.start(fn ->
      :timer.sleep(500)
      compile_all_schemas()
    end)

    {:ok, pid}
  end

  defp compile_all_schemas do
    case Compiler.compile_all_schemas() do
      :ok -> IO.puts("✅ Compiled and stored all schemas in Redis")
      {:error, reason} -> IO.puts("❌ Failed to compile schemas: #{inspect(reason)}")
    end
  end
end
