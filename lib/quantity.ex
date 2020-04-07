defmodule Quantity do
  @moduledoc """
  A data structure that encapsulates a decimal value with a unit.
  """

  alias Quantity.Math

  @type t :: %__MODULE__{
          value: Decimal.t(),
          unit: unit
        }

  @type unit :: base_unit | {:div | :mult, unit, unit}
  @type base_unit :: String.t() | 1

  defstruct [
    :value,
    :unit
  ]

  defdelegate add!(quantity_1, quantity_2), to: Math
  defdelegate add(quantity_1, quantity_2), to: Math
  defdelegate div(dividend, divisor), to: Math
  defdelegate inverse(quantity), to: Math
  defdelegate mult(quantity, quantity_or_scalar), to: Math
  defdelegate round(quantity, decimals), to: Math
  defdelegate sub!(quantity_1, quantity_2), to: Math
  defdelegate sub(quantity_1, quantity_2), to: Math
  defdelegate sum!(quantities), to: Math
  defdelegate sum!(quantities, exp, unit), to: Math
  defdelegate sum(quantities), to: Math
  defdelegate sum(quantities, exp, unit), to: Math

  @doc """
  Builds a new Quantity from a Decimal and a unit
  """
  @spec new(Decimal.t(), unit) :: t
  def new(value, unit) do
    unit = normalize_unit(unit)

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

  iex> Quantity.parse("15 m*m")
  {:ok, Quantity.new(~d[15], {:mult, "m", "m"})}

  iex> Quantity.parse("bogus")
  :error
  """
  @spec parse(String.t()) :: {:ok, t} | :error
  def parse(input) do
    with {:ok, value_string, unit_string} <- parse_split_value_and_unit(input),
         {:ok, value} <- Decimal.parse(value_string) do
      unit = parse_unit(unit_string)

      {:ok, new(value, unit)}
    else
      _ -> :error
    end
  end

  defp parse_split_value_and_unit(input) do
    case String.split(input, " ", parts: 2) do
      [value] -> {:ok, value, "1"}
      [value, unit] -> {:ok, value, unit}
      _ -> :error
    end
  end

  defp parse_unit(unit_string) do
    if unit_string =~ "/" do
      [:div | unit_string |> String.split("/", parts: 2) |> Enum.map(&parse_mult_unit/1)] |> List.to_tuple()
    else
      parse_mult_unit(unit_string)
    end
  end

  defp parse_mult_unit(unit_string) do
    unit_string
    |> String.split("*")
    |> Enum.map(&parse_base_unit/1)
    |> Enum.reduce(&{:mult, &1, &2})
  end

  defp parse_base_unit("1"), do: 1
  defp parse_base_unit(unit_string), do: unit_string

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
  iex> Quantity.new(~d[34], {:mult, "m", "m"}) |> Quantity.to_string()
  "34 m*m"
  """
  @spec to_string(t) :: String.t()
  def to_string(quantity) do
    decimal_string = decimal_to_string(quantity.value)

    unit_string =
      case quantity.unit do
        1 -> ""
        unit -> " #{unit_to_string(unit)}"
      end

    "#{decimal_string}#{unit_string}"
  end

  defp unit_to_string(1), do: "1"
  defp unit_to_string(unit) when is_binary(unit), do: unit
  defp unit_to_string({:div, a, b}), do: "#{unit_to_string(a)}/#{unit_to_string(b)}"
  defp unit_to_string({:mult, a, b}), do: "#{unit_to_string(a)}*#{unit_to_string(b)}"

  @doc """
  Encodes a decimal as string. Uses either :raw (E-notation) or :normal based on exponent, so that precision is not
  lost

  iex> Quantity.decimal_to_string(~d[1.234])
  "1.234"

  iex> Quantity.decimal_to_string(~d[1E3])
  "1E3"
  """
  @spec decimal_to_string(Decimal.t()) :: String.t()
  def decimal_to_string(%Decimal{} = decimal) do
    if decimal.exp > 0 do
      Decimal.to_string(decimal, :raw)
    else
      Decimal.to_string(decimal, :normal)
    end
  end

  @doc """
  Tests if a quantity has zero value

  iex> Quantity.zero?(~Q[0.00 m^2])
  true

  iex> Quantity.zero?(~Q[0E7 m^2])
  true

  iex> Quantity.zero?(~Q[10 m^2])
  false
  """
  @spec zero?(t) :: boolean
  def zero?(quantity), do: quantity.value.coef == 0

  @doc """
  Test whether a Quantity is negative

  iex> ~Q[100.00 DKK] |> Quantity.negative?()
  false

  iex> ~Q[0.00 DKK] |> Quantity.negative?()
  false

  iex> ~Q[-1.93 DKK] |> Quantity.negative?()
  true
  """
  @spec negative?(t) :: boolean()
  def negative?(%{value: value}), do: Decimal.negative?(value)

  @doc """
  Test whether a Quantity is positive

  iex> ~Q[100.00 DKK] |> Quantity.positive?()
  true

  iex> ~Q[0.00 DKK] |> Quantity.positive?()
  false

  iex> ~Q[-1.93 DKK] |> Quantity.positive?()
  false
  """
  @spec positive?(t) :: boolean()
  def positive?(%{value: value}), do: Decimal.positive?(value)

  @doc """
  Returns true if the two quantities are numerically equal

  iex> Quantity.equals?(~Q[5 bananas], ~Q[5.0 bananas])
  true

  iex> Quantity.equals?(~Q[5 bananas], ~Q[5 apples])
  false
  """
  @spec equals?(t, t) :: boolean
  def equals?(q1, q2) do
    reduce(q1) == reduce(q2)
  end

  @doc """
  Reduces the value to the largest possible exponent without altering the numerical value

  iex> Quantity.reduce(~Q[1.200 m])
  ~Q[1.2 m]
  """
  @spec reduce(t) :: t
  def reduce(quantity) do
    %{quantity | value: Decimal.reduce(quantity.value)}
  end

  @doc """
  Return a quantity with a zero value and the same unit and precision as another Quantity

  iex> ~Q[123.99 EUR] |> Quantity.to_zero()
  ~Q[0.00 EUR]

  iex> ~Q[1 person] |> Quantity.to_zero()
  ~Q[0 person]

  iex> ~Q[-123 seconds] |> Quantity.to_zero()
  ~Q[0 seconds]
  """
  @spec to_zero(t) :: t
  def to_zero(%{unit: unit, value: %Decimal{exp: exp}}), do: Quantity.new(0, exp, unit)

  @doc """
  Converts the quantity to have a new unit.
  The new unit must be a whole 10-exponent more or less than the original unit.

  The exponent given is the difference in exponents (new-exponent - old-exponent).
  For example when converting from kWh to MWh: 6 (MWh) - 3 (kWh) = 3

  iex> ~Q[1234E3 Wh] |> Quantity.convert_unit("MWh", 6)
  ~Q[1.234 MWh]

  iex> ~Q[25.2 m] |> Quantity.convert_unit("mm", -3)
  ~Q[252E2 mm]
  """
  @spec convert_unit(t, String.t(), integer) :: t
  def convert_unit(quantity, new_unit, exponent) do
    new(Decimal.new(quantity.value.sign, quantity.value.coef, quantity.value.exp - exponent), new_unit)
  end

  @doc """
  Compares two quantities with the same unit numerically

  iex> Quantity.compare(~Q[1.00 m], ~Q[2.00 m])
  :lt
  iex> Quantity.compare(~Q[1.00 m], ~Q[1 m])
  :eq
  iex> Quantity.compare(~Q[3.00 m], ~Q[2.9999999 m])
  :gt
  """
  @spec compare(t, t) :: :lt | :eq | :gt
  def compare(%{unit: unit} = q1, %{unit: unit} = q2) do
    Decimal.cmp(q1.value, q2.value)
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
  Converts a 1-unit quantity to a decimal. If the quantity does not represent a decimal (a unit other than 1) it fails.

  iex> Quantity.to_decimal!(~Q[42])
  ~d[42]
  """
  @spec to_decimal!(t) :: Decimal.t()
  def to_decimal!(%{unit: 1} = quantity), do: quantity.value

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

  # Normalizes unit to a standard form:
  # * Shorten unit as much as possible
  # * At most one :div (with possibly many :mults on each side)
  # * All :mult units are sorted
  # * Extra 1-units are removed
  defp normalize_unit(unit) do
    [numerators, denominators] =
      unit
      |> isolate_units([[], []])
      |> shorten()
      |> Enum.map(&Enum.sort/1)

    case {numerators, denominators} do
      {[], []} -> 1
      {nums, []} -> reduce_mults(nums)
      {[], dens} -> {:div, 1, reduce_mults(dens)}
      {nums, dens} -> {:div, reduce_mults(nums), reduce_mults(dens)}
    end
  end

  defp reduce_mults(units) do
    units
    |> Enum.reverse()
    |> Enum.reduce(&{:mult, &1, &2})
  end

  # Remove common elements in numerator and denominator
  defp shorten([numerators, denominators]) do
    [numerators, denominators] =
      [numerators, denominators]
      # Can be replaced with Enum.frequencies/1 when we no longer support Elixir 1.9
      |> Enum.map(fn list ->
        list |> Enum.group_by(& &1) |> Enum.into(%{}, fn {unit, count_list} -> {unit, length(count_list)} end)
      end)

    numerators
    |> Map.keys()
    |> Enum.reduce([numerators, denominators], fn key, [num, den] ->
      common = min(Map.fetch!(num, key), Map.get(den, key, 0))
      num = Map.update!(num, key, &(&1 - common))
      den = Map.update(den, key, 0, &(&1 - common))
      [num, den]
    end)
    |> Enum.map(fn map ->
      map |> Enum.flat_map(fn {key, count} -> List.duplicate(key, count) end)
    end)
  end

  # Splits units in numerators and denominators, so they are of the form (a * b * ...) / (c * d * ...)
  defp isolate_units({:div, a, b}, [acc_n, acc_d]) do
    [acc_n, acc_d] = isolate_units(a, [acc_n, acc_d])
    [acc_d, acc_n] = isolate_units(b, [acc_d, acc_n])
    [acc_n, acc_d]
  end

  defp isolate_units({:mult, a, b}, acc), do: Enum.reduce([a, b], acc, &isolate_units/2)
  defp isolate_units(a, [acc_n, acc_d]) when is_binary(a), do: [[a | acc_n], acc_d]
  defp isolate_units(1, acc), do: acc
end
