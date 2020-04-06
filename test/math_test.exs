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

  describe "inverse" do
    test "inverse of a quantity with simple unit" do
      assert Quantity.inverse(~Q[10 banana]) == ~Q[0.1 1/banana]
    end

    test "inverse of a quantity with 1/unit" do
      assert Quantity.inverse(~Q[0.1 1/banana]) == ~Q[1E1 banana]
    end

    test "inverse of a quantity with div unit" do
      assert Quantity.inverse(~Q[10 banana/hour]) == ~Q[0.1 hour/banana]
    end

    test "using 1/unit quantities in other Math functions" do
      assert ~Q[10 banana]
             |> Quantity.inverse()
             |> Quantity.mult(~d[50])
             |> Quantity.add!(~Q[5 1/banana])
             |> Quantity.inverse() ==
               ~Q[0.1 banana]
    end
  end

  describe "div" do
    test "dividing by quantity without unit" do
      assert Quantity.div(~Q[25 bananas], ~Q[5]) == ~Q[5 bananas]
    end

    test "dividing by 1/unit" do
      assert Quantity.div(~Q[25 bananas], ~Q[5 1/s]) == ~Q[5 bananas*s]
    end

    test "dividing 1 unit with regular quantity" do
      assert Quantity.div(~Q[25], ~Q[5 bananas]) == ~Q[5 1/bananas]
    end
  end

  describe "mult" do
    test "mutliplying by quantity without unit" do
      assert Quantity.mult(~Q[12 bananas], ~Q[3]) == ~Q[36 bananas]
    end

    test "mutliplying by quantity with 1/unit" do
      assert Quantity.mult(~Q[12 bananas], ~Q[3 1/s]) == ~Q[36 bananas/s]
    end

    test "mutliplying by quantity with 1/unit that matches" do
      assert Quantity.mult(~Q[12 s], ~Q[3 1/s]) == ~Q[36]
      assert Quantity.mult(~Q[12 s*s], ~Q[3 1/s]) == ~Q[36 s]
      assert Quantity.mult(~Q[12 s/banana], ~Q[3 1/s]) == ~Q[36 1/banana]
    end

    test "multiplying with inverse unit" do
      assert Quantity.mult(~Q[12 s/banana], ~Q[3 banana/s]) == ~Q[36]
    end
  end
end
