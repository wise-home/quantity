defmodule Quantity do
  @moduledoc """
  A data structure that encapsulates a decimal value with a unit.
  """

  @type t :: %__MODULE__{
          value: Decimal.t(),
          unit: unit
        }

  @type unit :: String.t() | {:div, String.t(), String.t()}

  defstruct [
    :value,
    :unit
  ]

  defdelegate add(quantity_1, quantity_2), to: Quantity.Math
  defdelegate add!(quantity_1, quantity_2), to: Quantity.Math
  defdelegate sub(quantity_1, quantity_2), to: Quantity.Math
  defdelegate sub!(quantity_1, quantity_2), to: Quantity.Math
  defdelegate sum(quantities), to: Quantity.Math
  defdelegate sum(quantities, exp, unit), to: Quantity.Math
  defdelegate sum!(quantities), to: Quantity.Math
  defdelegate sum!(quantities, exp, unit), to: Quantity.Math
  defdelegate div(dividend, divisor), to: Quantity.Math

  @doc """
  Builds a new Quantity from a Decimal and a unit
  """
  @spec new(Decimal.t(), unit) :: t
  def new(value, unit) do
    %__MODULE__{
      value: value,
      unit: unit
    }
  end

  @doc """
  Builds a new Quantity from a base value, exponent and unit
  """
  @spec new(integer, integer, unit) :: t
  def new(base_value, exponent, unit) do
    sign = if base_value < 0, do: -1, else: 1
    positive_base_value = abs(base_value)
    value = Decimal.new(sign, positive_base_value, exponent)
    new(value, unit)
  end

  @doc """
  Parses a string representation of a quantity (perhaps generated with to_string/1)

  iex> Quantity.parse("99.0 red_balloons")
  {:ok, Quantity.new(~d[99.0], "red_balloons")}

  iex> Quantity.parse("15 bananas/monkey")
  {:ok, Quantity.new(~d[15], {:div, "bananas", "monkey"})}

  iex> Quantity.parse("bogus")
  :error
  """
  @spec parse(String.t()) :: {:ok, t} | :error
  def parse(input) do
    with [value_string, unit_string] <- String.split(input, " ", parts: 2),
         {:ok, value} <- Decimal.parse(value_string) do
      unit =
        case String.split(unit_string, "/", parts: 2) do
          [unit] -> unit
          [u1, u2] -> {:div, u1, u2}
        end

      {:ok, new(value, unit)}
    else
      _ -> :error
    end
  end

  @doc """
  Same as parse/1, but raises if it could not parse
  """
  @spec parse!(String.t()) :: t
  def parse!(input) do
    {:ok, quantity} = parse(input)
    quantity
  end

  @doc """
  Encodes the quantity as a string. The result is parsable with parse/1
  If the exponent is positive, encode usinge the "raw" format to preserve precision

  iex> Quantity.new(42, -1, "db") |> Quantity.to_string()
  "4.2 db"
  iex> Quantity.new(42, 1, "db") |> Quantity.to_string()
  "42E1 db"
  iex> Quantity.new(~d[3600], {:div, "seconds", "hour"}) |> Quantity.to_string()
  "3600 seconds/hour"
  """
  @spec to_string(t) :: String.t()
  def to_string(quantity) do
    decimal_string =
      if quantity.value.exp > 0 do
        Decimal.to_string(quantity.value, :raw)
      else
        Decimal.to_string(quantity.value, :normal)
      end

    unit_string =
      case quantity.unit do
        {:div, u1, u2} -> "#{u1}/#{u2}"
        unit -> unit
      end

    "#{decimal_string} #{unit_string}"
  end

  @doc """
  Extracts the base value from the quantity
  """
  @spec base_value(t) :: integer
  def base_value(quantity), do: quantity.value.coef * quantity.value.sign

  @doc """
  Extracts the exponent from the quantity
  """
  @spec exponent(t) :: integer
  def exponent(quantity), do: quantity.value.exp

  @doc """
  Extracts the unit from the quantity
  """
  @spec unit(t) :: unit
  def unit(quantity), do: quantity.unit

  defimpl String.Chars, for: __MODULE__ do
    def to_string(quantity) do
      @for.to_string(quantity)
    end
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(quantity, _options) do
      "~Q[#{@for.to_string(quantity)}]"
    end
  end
end
