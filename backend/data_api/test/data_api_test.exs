defmodule DataApiTest do
  use ExUnit.Case
  import Plug.Test

  @opts DataApi.Router.init([])

  setup do
    Ecto.Adapters.SQL.query!(DataApi.Repo, "DELETE FROM users", [])

    Ecto.Adapters.SQL.query!(
      DataApi.Repo,
      """
      INSERT INTO users (name, email, role)
      VALUES ('Alice', 'alice@example.com', 'admin')
      """,
      []
    )

    :ok
  end

  test "GET /schema/users returns columns" do
    conn = conn(:get, "/schema/users")
    conn = DataApi.Router.call(conn, @opts)

    assert conn.status == 200
    assert %{"columns" => columns} = Jason.decode!(conn.resp_body)
    assert is_list(columns)
  end

  test "GET /data/users returns data" do
    conn = conn(:get, "/data/users")
    conn = DataApi.Router.call(conn, @opts)

    assert conn.status == 200
    result = Jason.decode!(conn.resp_body)

    assert is_map(result)
    assert is_list(result["rows"])
    assert Enum.any?(result["rows"], fn row -> row["name"] == "Alice" end)
  end
end
