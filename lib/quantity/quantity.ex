defmodule Quantity do
  @moduledoc """
  A data structure that encapsulates a decimal value with a unit.
  """

  @type t :: %__MODULE__{
          value: Decimal.t(),
          unit: String.t()
        }

  defstruct [
    :value,
    :unit
  ]

  @doc """
  Builds a new Quantity from a Decimal and a unit
  """
  @spec new(Decimal.t(), String.t()) :: t
  def new(value, unit) do
    %__MODULE__{
      value: value,
      unit: unit
    }
  end

  @doc """
  Builds a new Quantity from a base value, exponent and unit
  """
  @spec new(integer, integer, String.t()) :: t
  def new(base_value, exponent, unit) do
    sign = if base_value < 0, do: -1, else: 1
    positive_base_value = abs(base_value)
    value = Decimal.new(sign, positive_base_value, exponent)
    new(value, unit)
  end

  @doc """
  Parses a string representation of a quantity (perhaps generated with to_string/1)
  """
  @spec parse(String.t()) :: {:ok, t} | :error
  def parse(input) do
    with [value_string, unit] <- String.split(input, " ", parts: 2),
         {:ok, value} <- Decimal.parse(value_string) do
      {:ok, new(value, unit)}
    else
      _ -> :error
    end
  end

  @doc """
  Same as parse/1, but errors if it could not parse
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
  """
  @spec to_string(t) :: String.t()
  def to_string(quantity) do
    decimal_string =
      if quantity.value.exp > 0 do
        Decimal.to_string(quantity.value, :raw)
      else
        Decimal.to_string(quantity.value, :normal)
      end

    "#{decimal_string} #{quantity.unit}"
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
  @spec unit(t) :: String.t()
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
