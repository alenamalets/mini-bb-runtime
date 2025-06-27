defmodule DataApi.Application do
  use Application

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start(_type, _args) do
    children = [
      DataApi.Repo,
      {Redix, host: @default_host, port: @default_port, name: :redis_server},
      {Plug.Cowboy, scheme: :http, plug: DataApi.Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: DataApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
