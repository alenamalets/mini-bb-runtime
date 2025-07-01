import Config

config :data_api, DataApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "data_api_test",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox
