ExUnit.start()

# Load Redis schema for test
{:ok, _} = Redix.start_link(name: :redis_server)

schema = %{"table" => "users", "columns" => ["name", "email", "role"]}
Redix.command!(:redis_server, ["SET", "compiled_schema:users", Jason.encode!(schema)])
