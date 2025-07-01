defmodule DataApi.Redis do
  @moduledoc """
  Simple Redis wrapper using Redix with JSON decoding.
  """

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start_link() do
    Redix.start_link(host: @default_host, port: @default_port, name: :redis)
  end

  def get(key, conn \\ nil) do
    conn = conn || default_redix_name()

    case Redix.command!(conn, ["GET", key]) do
      nil -> nil
      json -> Jason.decode!(json)
    end
  end

  defp default_redix_name do
    if Mix.env() == :test, do: Redix, else: :redis_server
  end
end
