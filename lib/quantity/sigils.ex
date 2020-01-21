defmodule Quantity.Sigils do
  @moduledoc """
  Sigils related to Quantity and Decimal
  """

  @doc """
  Construct a Decimal

  iex> ~d[12.340]
  Decimal.new("12.340")
  """
  @spec sigil_d(String.t(), []) :: Decimal.t()
  def sigil_d(input, []) do
    Decimal.new(input)
  end

  @doc """
  Construct a Quantity

  iex> ~Q[12.340 kwh]
  Quantity.new(~d[12.340], "kwh")

  iex> ~Q[15 $/banana]
  Quantity.new(~d[15], {:div, "$", "banana"})

  iex> ~Q[12.34 m*m]
  Quantity.new(~d[12.34], {:mult, "m", "m"})
  """
  @spec sigil_Q(String.t(), []) :: Quantity.t()
  def sigil_Q(input, []) do
    Quantity.parse!(input)
  end
end
