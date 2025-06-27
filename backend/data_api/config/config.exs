import(Config)

config :data_api, DataApi.Repo,
  database: "mini_bb",
  username: "postgres",
  password: "postgres",
  hostname: "postgres"

config :data_api, ecto_repos: [DataApi.Repo]
