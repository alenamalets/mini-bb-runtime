defmodule DataApiTest do
  use ExUnit.Case
  doctest DataApi

  test "greets the world" do
    assert DataApi.hello() == :world
  end
end
