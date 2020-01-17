defmodule Quantity.MathTest do
  @moduledoc """
  Tests for Quantity.Math
  """

  use Quantity.Test.Case

  import Quantity.Math
  doctest Quantity.Math

  describe "add!" do
    test "raises ArgumentError when adding two quantities with different units" do
      assert_raise(ArgumentError, fn -> Quantity.add!(~Q[1 apple], ~Q[1 banana]) end)
    end
  end

  describe "sub!" do
    test "raises ArgumentError when subtracting two quantities with different units" do
      assert_raise(ArgumentError, fn -> Quantity.sub!(~Q[4 mice], ~Q[3 men]) end)
    end
  end

  describe "sum!/1" do
    test "raises ArgumentError when summing quantities with different units" do
      assert_raise(ArgumentError, fn -> Quantity.sum!([~Q[123 bananas], ~Q[456 apples]]) end)
    end

    test "raises ArgumentError when summing an empty list" do
      assert_raise(ArgumentError, fn -> Quantity.sum!([]) end)
    end
  end

  describe "sum!/3" do
    test "raises ArgumentError when summing quantities with different units" do
      assert_raise(ArgumentError, fn -> Quantity.sum!([~Q[123 bananas], ~Q[456 apples]], 0, "apples") end)
    end
  end
end
