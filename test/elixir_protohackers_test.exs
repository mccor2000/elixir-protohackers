defmodule ElixirProtohackersTest do
  use ExUnit.Case
  doctest ElixirProtohackers

  test "greets the world" do
    assert ElixirProtohackers.hello() == :world
  end
end
