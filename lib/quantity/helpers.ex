defmodule Quantity.Helpers do
  @moduledoc """
  Helpers related to Quantity and Decimal
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
  """
  @spec sigil_Q(String.t(), []) :: Quantity.t()
  def sigil_Q(input, []) do
    Quantity.parse!(input)
  end
end
