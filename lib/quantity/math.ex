defmodule Quantity.Math do
  @moduledoc """
  Functions for doing math with Quantities
  """

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
  ~d[1.5]
  """
  @spec div(Quantity.t(), Quantity.t() | Decimal.t()) :: Quantity.t() | Decimal.t()

  def div(%Quantity{unit: unit} = q1, %Quantity{unit: unit} = q2) do
    Decimal.div(q1.value, q2.value)
  end

  def div(%Quantity{} = q1, %Quantity{} = q2) do
    Quantity.new(Decimal.div(q1.value, q2.value), {:div, q1.unit, q2.unit})
  end

  def div(%Quantity{} = quantity, %Decimal{} = scalar) do
    Quantity.new(Decimal.div(quantity.value, scalar), quantity.unit)
  end

  @doc """
  Inverse a Quantity, similar to 1/quantity

  iex> Quantity.inverse(~Q[10 DKK/m³])
  ~Q[0.1 m³/DKK]
  """
  @spec inverse(Quantity.t()) :: Quantity.t()
  def inverse(%Quantity{unit: {:div, nil, unit}} = quantity) do
    Quantity.new(Decimal.div(1, quantity.value), unit)
  end

  def inverse(%Quantity{unit: {:div, unit_a, unit_b}} = quantity) do
    Quantity.new(Decimal.div(1, quantity.value), {:div, unit_b, unit_a})
  end

  def inverse(quantity) do
    Quantity.new(Decimal.div(1, quantity.value), {:div, nil, quantity.unit})
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
    Quantity.new(Decimal.mult(quantity.value, scalar), quantity.unit)
  end

  def mult(%Quantity{unit: {:div, unit, common_unit}} = q1, %Quantity{unit: common_unit} = q2) do
    Quantity.new(Decimal.mult(q1.value, q2.value), unit)
  end

  def mult(%Quantity{unit: common_unit} = q1, %Quantity{unit: {:div, unit, common_unit}} = q2) do
    Quantity.new(Decimal.mult(q1.value, q2.value), unit)
  end

  def mult(%Quantity{} = q1, %Quantity{} = q2) do
    Quantity.new(Decimal.mult(q1.value, q2.value), {:mult, q1.unit, q2.unit})
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
end
