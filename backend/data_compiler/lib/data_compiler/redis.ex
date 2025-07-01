defmodule DataCompiler.Redis do
  @moduledoc """
  Simple Redis wrapper using Redix with JSON encoding.
  """

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start_link() do
    Redix.start_link(host: @default_host, port: @default_port, name: default_redix_name())
  end

  def set(key, value, conn \\ nil) do
    conn = conn || default_redix_name()
    encoded = Jason.encode!(value)
    Redix.command!(conn, ["SET", key, encoded])
  end

  defp default_redix_name do
    if Mix.env() == :test, do: Redix, else: :redis_server
  end
end
