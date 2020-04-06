defmodule Quantity.Math do
  @moduledoc """
  Functions for doing math with Quantities
  """

  import Kernel, except: [div: 2]

  @doc """
  Add two Quantities, keeping the unit

  iex> add(~Q[1.34 MWh], ~Q[3.49 MWh])
  {:ok, ~Q[4.83 MWh]}

  iex> add(~Q[1.234567 days], ~Q[3.5 days])
  {:ok, ~Q[4.734567 days]}

  iex> add(~Q[10 goats], ~Q[40 sheep])
  :error
  """
  @spec add(Quantity.t(), Quantity.t()) :: {:ok, Quantity.t()} | :error
  def add(%{unit: unit} = a, %{unit: unit} = b) do
    {:ok, Quantity.new(Decimal.add(a.value, b.value), unit)}
  end

  def add(_, _) do
    :error
  end

  @doc """
  Add two Quantities, but raise an ArgumentError on error

  iex> add!(~Q[50.94 kWh], ~Q[49.40 kWh])
  ~Q[100.34 kWh]
  """
  @spec add!(Quantity.t(), Quantity.t()) :: Quantity.t()
  def add!(a, b) do
    case add(a, b) do
      {:ok, result} -> result
      :error -> raise(ArgumentError)
    end
  end

  @doc """
  Subtract two Quantities, keeping the unit

  iex> sub(~Q[99 bottles of beer], ~Q[2 bottles of beer])
  {:ok, ~Q[97 bottles of beer]}

  iex> sub(~Q[2 bananas], ~Q[1 apple])
  :error
  """
  @spec sub(Quantity.t(), Quantity.t()) :: {:ok, Quantity.t()} | :error
  def sub(%{unit: unit} = a, %{unit: unit} = b) do
    {:ok, Quantity.new(Decimal.sub(a.value, b.value), unit)}
  end

  def sub(_, _) do
    :error
  end

  @doc """
  Subtract two Quantities, but raise ArgumentError on error

  iex> sub!(~Q[99 problems], ~Q[2 problems])
  ~Q[97 problems]
  """
  @spec sub!(Quantity.t(), Quantity.t()) :: Quantity.t()
  def sub!(a, b) do
    case sub(a, b) do
      {:ok, result} -> result
      :error -> raise(ArgumentError)
    end
  end

  @doc """
  Sum a list of Quantities with identical units. Errors when addition fails or when the list is empty.

  iex> sum([~Q[11.11 DKK], ~Q[22.22 DKK], ~Q[33.33 DKK]])
  {:ok, ~Q[66.66 DKK]}

  iex> sum([~Q[1 EUR], ~Q[2 DKK]])
  :error

  iex> sum([])
  :error
  """
  @spec sum([Quantity.t()]) :: {:ok, Quantity.t()} | :error
  def sum([]), do: :error

  def sum(quantities) do
    {first, remaining} = quantities |> List.pop_at(0)

    remaining
    |> Enum.reduce_while(first, fn quantity, acc ->
      case add(quantity, acc) do
        {:ok, result} -> {:cont, result}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      :error -> :error
      result -> {:ok, result}
    end
  end

  @doc """
  Sum a list of Quantities with identical units. Includes a fallback value.
  The exp and unit will be used to create a Quantity with value 0 if the list is empty.

  iex> sum([~Q[0.11 DKK], ~Q[0.22 DKK], ~Q[0.33 DKK]], -2, "DKK")
  {:ok, ~Q[0.66 DKK]}

  iex> sum([], 0, "DKK")
  {:ok, ~Q[0 DKK]}

  iex> sum([], -2, "DKK")
  {:ok, ~Q[0.00 DKK]}

  iex> sum([~Q[1 EUR], ~Q[2 DKK]], -2, "EUR")
  :error
  """
  @spec sum([Quantity.t()], integer, String.t()) :: {:ok, Quantity.t()} | :error
  def sum([], exp, unit), do: {:ok, Quantity.new(0, exp, unit)}

  def sum(quantities, _exp, _unit), do: quantities |> sum()

  @doc """
  Sum a list of Quantities with identical units, raises ArgumentError on error

  iex> sum!([~Q[123 DKK], ~Q[10 DKK], ~Q[39 DKK]])
  ~Q[172 DKK]
  """
  @spec sum!([Quantity.t()]) :: Quantity.t()
  def sum!(quantities) do
    case sum(quantities) do
      {:ok, result} -> result
      :error -> raise(ArgumentError)
    end
  end

  @doc """
  Sum a list of Quantities with identical units. Includes a fallback value.
  The exp and unit will be used to create a Quantity with value 0 if the list is empty.
  Raises ArgumentError on error.

  iex> sum!([~Q[123 apples], ~Q[10 apples]], 0, "apples")
  ~Q[133 apples]

  iex> sum!([], -2, "DKK")
  ~Q[0.00 DKK]
  """
  @spec sum!([Quantity.t()], integer, String.t()) :: Quantity.t()
  def sum!(quantities, exp, unit) do
    case sum(quantities, exp, unit) do
      {:ok, result} -> result
      :error -> raise(ArgumentError)
    end
  end

  @doc """
  Divide a Quantity by a scalar or another Quantity

  iex> Quantity.div(~Q[15 $], ~Q[10 banana])
  ~Q[1.5 $/banana]

  iex> Quantity.div(~Q[15 $], ~d[10])
  ~Q[1.5 $]

  iex> Quantity.div(~Q[15 $], ~Q[10 $])
  ~Q[1.5]
  """
  @spec div(Quantity.t(), Quantity.t() | Decimal.t()) :: Quantity.t()
  def div(%Quantity{} = quantity, %Decimal{} = scalar) do
    div(quantity, Quantity.new(scalar, 1))
  end

  def div(%Quantity{} = q1, %Quantity{} = q2) do
    Quantity.new(Decimal.div(q1.value, q2.value), reduce_unit({:div, q1.unit, q2.unit}))
  end

  @doc """
  Inverse a Quantity, similar to 1/quantity

  iex> Quantity.inverse(~Q[10 DKK/m³])
  ~Q[0.1 m³/DKK]
  """
  @spec inverse(Quantity.t()) :: Quantity.t()
  def inverse(%Quantity{} = quantity) do
    div(Quantity.new(Decimal.new(1), 1), quantity)
  end

  @doc """
  Multiply a quantity by a scalar or another quantity

  iex> Quantity.mult(~Q[15 $], ~d[4])
  ~Q[60 $]

  iex> Quantity.mult(~Q[15 $], ~Q[4 banana])
  ~Q[60 $*banana]

  iex> Quantity.mult(~Q[15 $/banana], ~Q[4 banana])
  ~Q[60 $]
  """
  @spec mult(Quantity.t(), Quantity.t() | Decimal.t()) :: Quantity.t()
  def mult(%Quantity{} = quantity, %Decimal{} = scalar) do
    mult(quantity, Quantity.new(scalar, 1))
  end

  def mult(%Quantity{} = q1, %Quantity{} = q2) do
    Quantity.new(Decimal.mult(q1.value, q2.value), reduce_unit({:mult, q1.unit, q2.unit}))
  end

  @doc """
  Round a Quantity to match a precision using the :half_up strategy

  iex> Quantity.round(~Q[1.49 DKK], 1)
  ~Q[1.5 DKK]

  iex> Quantity.round(~Q[0.5 DKK], 2)
  ~Q[0.50 DKK]
  """
  def round(quantity, decimal_count) do
    Quantity.new(Decimal.round(quantity.value, decimal_count, :half_up), quantity.unit)
  end

  defp reduce_unit(unit) do
    {numerators, denominators} =
      unit
      |> isolate_units({[], []})
      |> shorten()

    case {numerators, denominators} do
      {[], []} -> 1
      {[a], []} -> a
      {[], [a]} -> {:div, 1, a}
      {[a, b], []} -> {:mult, a, b}
      {[a], [b]} -> {:div, a, b}
      # Everything below here is not valid, but we try anyway
      {as, []} -> Enum.reduce(as, &{:mult, &1, &2})
      {[], bs} -> {:div, 1, Enum.reduce(bs, &{:mult, &1, &2})}
      {as, bs} -> {:div, Enum.reduce(as, &{:mult, &1, &2}), Enum.reduce(bs, &{:mult, &1, &2})}
    end
  end

  defp shorten({numerators, denominators}) do
    [numerators, denominators] =
      [numerators, denominators]
      # Can be replaced with Enum.frequencies/1 when we no longer support Elixir 1.9
      |> Enum.map(fn list ->
        list |> Enum.group_by(& &1) |> Enum.into(%{}, fn {unit, count_list} -> {unit, length(count_list)} end)
      end)

    [numerators, denominators] =
      numerators
      |> Map.keys()
      |> Enum.reduce([numerators, denominators], fn key, [num, den] ->
        common = min(Map.fetch!(num, key), Map.get(den, key, 0))
        num = Map.update!(num, key, &(&1 - common))
        den = Map.update(den, key, 0, &(&1 - common))
        [num, den]
      end)
      |> Enum.map(fn map -> map |> Enum.flat_map(fn {key, count} -> List.duplicate(key, count) end) |> Enum.sort() end)

    {numerators, denominators}
  end

  # Splits units in nominators and denominators, so they are of the form (a * b * ...) / (c * d * ...)
  defp isolate_units({:div, a, b}, {acc_n, acc_d}) do
    {acc_n, acc_d} = isolate_units(a, {acc_n, acc_d})
    {acc_d, acc_n} = isolate_units(b, {acc_d, acc_n})
    {acc_n, acc_d}
  end

  defp isolate_units({:mult, a, b}, acc), do: Enum.reduce([a, b], acc, &isolate_units/2)
  defp isolate_units(a, {acc_n, acc_d}) when is_binary(a), do: {[a | acc_n], acc_d}
  defp isolate_units(1, acc), do: acc
end
