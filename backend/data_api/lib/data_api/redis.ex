defmodule DataApi.Redis do
  @moduledoc """
  Simple Redis wrapper using Redix with JSON decoding.
  """

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start_link() do
    Redix.start_link(host: @default_host, port: @default_port, name: :redis)
  end

  def get(key, conn \\ :redis_server) do
    case Redix.command!(conn, ["GET", key]) do
      nil -> nil
      json -> Jason.decode!(json)
    end
  end
end
