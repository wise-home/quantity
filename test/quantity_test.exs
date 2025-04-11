defmodule QuantityTest do
  use Quantity.Test.Case
  doctest Quantity

  test "parsing and encoding" do
    examples = [
      "12.45 DKK",
      "65465465465465464.64654654654654654 kw/h",
      "0 units",
      "5 super powers",
      "42E1 wh",
      "10 1/s",
      "10",
      "1 a*b*c/d*e*f",
      "1 a*b"
    ]

    Enum.each(examples, fn input ->
      {:ok, parsed} = Quantity.parse(input)
      encoded = Quantity.to_string(parsed)

      assert encoded == input
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

  test "parsing non-number decimal" do
    assert Quantity.parse("inf bananas") == :error
  end

  test "complex unit" do
    assert {:ok, quantity} = Quantity.parse("1 a*b*c/d*e*f")
    assert quantity.unit == {:div, {:mult, "a", {:mult, "b", "c"}}, {:mult, "d", {:mult, "e", "f"}}}
    assert Quantity.to_string(quantity) == "1 a*b*c/d*e*f"
  end

  test "inspecting" do
    assert ~Q[12.45 DKK] |> inspect() == "~Q[12.45 DKK]"
  end

  test "text interpolating" do
    assert "#{~Q[12.45 DKK]}" == "12.45 DKK"
  end

  test "to_string for 1-unit" do
    assert Quantity.to_string(~Q[42]) == "42"
  end

  test "encode to json from map" do
    assert %{quantity: ~Q[12.45 DKK]} |> Jason.encode!() == ~S|{"quantity":"12.45 DKK"}|
  end

  test "for non-number decimals" do
    ["inf", "-inf", "nan"]
    |> Enum.each(fn not_number ->
      catch_error(not_number |> Decimal.new() |> Quantity.new("unit"))
    end)
  end

  test "try_new" do
    assert Quantity.try_new(~d[1], "banana") == {:ok, ~Q[1 banana]}
    assert Quantity.try_new(~d[inf], "banana") == {:error, "Infinity not supported by Quantity"}
  end
end
