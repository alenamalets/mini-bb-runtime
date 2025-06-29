defmodule DataCompiler.Redis do
  @moduledoc """
  Simple Redis wrapper using Redix with JSON encoding.
  """

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start_link() do
    Redix.start_link(host: @default_host, port: @default_port, name: :redis_server)
  end

  def set(key, value, conn \\ :redis_server) do
    encoded = Jason.encode!(value)
    Redix.command!(conn, ["SET", key, encoded])
  end
end
