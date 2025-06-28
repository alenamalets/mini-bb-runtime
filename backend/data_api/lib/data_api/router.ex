defmodule DataApi.Router do
  use Plug.Router
  require Logger

  alias DataApi.SchemaBuilder

  plug(:match)
  plug(:dispatch)

  # Manually create "users" table
  get "/create-table" do
    schema = %{
      "table" => "users",
      "columns" => ["id", "name", "email"]
    }

    case SchemaBuilder.create(schema) do
      :ok -> send_resp(conn, 200, "✅ Table created!")
      {:error, reason} -> send_resp(conn, 500, "❌ Failed to create table: #{inspect(reason)}")
    end
  end

  # Read schema from Redis and respond
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
