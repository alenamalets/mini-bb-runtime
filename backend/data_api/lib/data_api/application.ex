defmodule DataApi.Application do
  use Application

  @default_host System.get_env("REDIS_HOST", "redis")
  @default_port String.to_integer(System.get_env("REDIS_PORT", "6379"))

  def start(_type, _args) do
    children =
      if Mix.env() == :test do
        [DataApi.Repo, {Redix, name: Redix}]
      else
        [
          DataApi.Repo,
          {Redix, host: @default_host, port: @default_port, name: :redis_server},
          {Plug.Cowboy, scheme: :http, plug: DataApi.Router, options: [port: 4001]}
        ]
      end

    opts = [strategy: :one_for_one, name: DataApi.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        run_migrations()
        run_seed_data()
        {:ok, pid}

      error ->
        error
    end
  end

  defp run_migrations do
    path = Application.app_dir(:data_api, "priv/repo/migrations")
    Ecto.Migrator.run(DataApi.Repo, path, :up, all: true)
  end

  defp run_seed_data do
    Ecto.Adapters.SQL.query!(
      DataApi.Repo,
      """
      INSERT INTO users (name, email, role)
      VALUES
        ('Alice', 'alice@example.com', 'owner'),
        ('Bob', 'bob@example.com', 'admin'),
        ('Charlie', 'charlie@example.com', 'user')
      ON CONFLICT DO NOTHING
      """
    )
  end
end
