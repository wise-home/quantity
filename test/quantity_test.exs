defmodule QuantityTest do
  use Quantity.Test.Case
  doctest Quantity

  test "parsing and encoding" do
    examples = [
      ~Q[12.45 DKK],
      ~Q[65465465465465464.64654654654654654 kw/h],
      ~Q[0 units],
      ~Q[5 super powers],
      ~Q[42E1 wh],
      ~Q[10 1/s],
      ~Q[10]
    ]

    Enum.each(examples, fn quantity ->
      encoded = Quantity.to_string(quantity)
      {:ok, parsed} = Quantity.parse(encoded)

      assert is_binary(encoded)
      assert parsed == quantity
    end)
  end

  test "parsing with 1 unit" do
    assert {:ok, quantity} = Quantity.parse("42")
    assert quantity.unit == 1
  end

  test "parsing 1/unit units" do
    assert {:ok, quantity} = Quantity.parse("1 1/unit")
    assert quantity.unit == {:div, 1, "unit"}
  end

  test "inspecting" do
    assert ~Q[12.45 DKK] |> inspect() == "~Q[12.45 DKK]"
  end

  test "text interpolating" do
    assert "#{~Q[12.45 DKK]}" == "12.45 DKK"
  end
end
