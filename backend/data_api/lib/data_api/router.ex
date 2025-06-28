defmodule DataApi.Router do
  use Plug.Router
  require Logger

  alias DataApi.SchemaBuilder

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

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

  # Populate "users" table with test data
  get "/populate" do
    key = "compiled_schema:users"

    case Redix.command!(:redis_server, ["GET", key]) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Schema not found"}))

      json ->
        schema = Jason.decode!(json)

        case SchemaBuilder.insert_test_data(schema) do
          :ok -> send_resp(conn, 200, "✅ Test data inserted!")
          {:error, reason} -> send_resp(conn, 500, "❌ Failed to insert data: #{inspect(reason)}")
        end
    end
  end

  # fetch data from a specific table
  get "/data/:table" do
    table = String.to_atom(table)
    params = Plug.Conn.fetch_query_params(conn).params

    # Filtering
    filters =
      case params["filter"] do
        nil ->
          []

        filter_map ->
          Enum.map(filter_map, fn {k, v} -> "#{k} = '#{v}'" end)
      end

    where_clause =
      case filters do
        [] -> ""
        _ -> "WHERE " <> Enum.join(filters, " AND ")
      end

    IO.inspect(where_clause, label: "where_clause")
    # Sorting
    sort = Map.get(params, "sort", nil)
    order = Map.get(params, "order", "asc")

    order_clause =
      if sort do
        "ORDER BY #{sort} #{String.upcase(order)}"
      else
        ""
      end

    # Pagination
    limit = Map.get(params, "limit", "10") |> String.to_integer()
    page = Map.get(params, "page", "1") |> String.to_integer()
    offset = (page - 1) * limit

    sql = """
    SELECT * FROM #{table}
    #{where_clause}
    #{order_clause}
    LIMIT #{limit} OFFSET #{offset}
    """

    IO.inspect(sql, label: "Final SQL")

    case Ecto.Adapters.SQL.query(DataApi.Repo, sql, []) do
      {:ok, %{rows: rows, columns: columns}} ->
        result =
          Enum.map(rows, fn row ->
            Enum.zip(columns, row) |> Enum.into(%{})
          end)

        send_resp(conn, 200, Jason.encode!(result))

      {:error, reason} ->
        send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # Insert data into a specific table
  post "/data/:table" do
    IO.inspect(conn.body_params, label: "Parsed Body Params")

    data = conn.body_params
    columns = Map.keys(data)
    values = Map.values(data)

    column_list = Enum.join(columns, ", ")
    placeholders = Enum.map(1..length(columns), &"$#{&1}") |> Enum.join(", ")

    sql = "INSERT INTO #{table} (#{column_list}) VALUES (#{placeholders})"

    case Ecto.Adapters.SQL.query(DataApi.Repo, sql, values) do
      {:ok, _result} ->
        send_resp(conn, 201, Jason.encode!(%{status: "created"}))

      {:error, reason} ->
        send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # Read schema from Redis and respond
  get "/schema/:table" do
    key = "compiled_schema:#{table}"

    case Redix.command!(:redis_server, ["GET", key]) do
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
