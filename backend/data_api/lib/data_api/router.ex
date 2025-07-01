defmodule DataApi.Router do
  use Plug.Router
  require Logger

  alias DataApi.SchemaBuilder
  alias DataApi.Redis

  plug(:match)

  plug(CORSPlug, origin: ["http://localhost:3000"])

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  # Get schema definition from Redis
  get "/schema/:table" do
    key = "compiled_schema:#{table}"

    case Redis.get(key) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Schema not found"}))

      data ->
        send_resp(conn, 200, Jason.encode!(data))
    end
  end

  # Get data from a specific table with filtering, sorting, and pagination
  get "/data/:table" do
    table = String.to_atom(table)
    params = Plug.Conn.fetch_query_params(conn).params

    # --- Filtering ---
    where_clause =
      case params["filter"] do
        nil ->
          ""

        filter_map ->
          conditions =
            Enum.map(filter_map, fn {k, v} ->
              "#{k} ILIKE '%#{v}%'"
            end)

          "WHERE " <> Enum.join(conditions, " OR ")
      end

    # --- Sorting ---
    sort = Map.get(params, "sort", nil)

    order_clause =
      if sort do
        "ORDER BY #{sort} ASC"
      else
        ""
      end

    # --- Pagination ---
    limit = Map.get(params, "limit", "10") |> String.to_integer()
    page = Map.get(params, "page", "1") |> String.to_integer()
    offset = (page - 1) * limit

    # --- Count total rows (without pagination) ---
    count_sql = """
    SELECT COUNT(*) FROM #{table}
    #{where_clause}
    """

    total =
      case Ecto.Adapters.SQL.query(DataApi.Repo, count_sql, []) do
        {:ok, %{rows: [[count]]}} -> count
        _ -> 0
      end

    # --- Main data query with LIMIT + OFFSET ---
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

        send_resp(
          conn,
          200,
          Jason.encode!(%{
            rows: result,
            total_count: total
          })
        )

      {:error, reason} ->
        send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # Insert data into a specific table
  post "/data/:table" do
    IO.inspect(conn.body_params, label: "Parsed Body Params")

    data = Map.put_new(conn.body_params, "id", UUID.uuid4())
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

  # Insert test data into a table
  # Test/dev endpoint
  get "/populate" do
    key = "compiled_schema:users"

    case Redis.get(key) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Schema not found"}))

      schema ->
        case SchemaBuilder.insert_test_data(schema) do
          :ok -> send_resp(conn, 200, "✅ Test data inserted!")
        end
    end
  end

  # Create a table dynamically from Redis schema
  # Test/dev endpoint
  post "/create-table/:table" do
    key = "compiled_schema:#{table}"

    case Redis.get(key) do
      nil ->
        send_resp(conn, 404, Jason.encode!(%{error: "Schema not found"}))

      json ->
        schema = json

        case SchemaBuilder.create(schema) do
          :ok -> send_resp(conn, 200, "✅ Table created!")
          {:error, reason} -> send_resp(conn, 500, "❌ Failed to create table: #{inspect(reason)}")
        end
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Route not found"}))
  end
end
