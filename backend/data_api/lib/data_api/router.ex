defmodule DataApi.Router do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  get "/schema/:table" do
    key = "compiled_schema:#{table}"

    case Redix.command!(:redis, ["GET", key]) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Schema not found"}))

      json ->
        send_resp(conn, 200, json)
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Route not found"}))
  end
end
