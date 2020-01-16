defmodule QuantityTest do
  use ExUnit.Case
  doctest Quantity

  test "greets the world" do
    assert Quantity.hello() == :world
  end
end
