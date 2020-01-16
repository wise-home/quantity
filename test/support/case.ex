defmodule Quantity.Test.Case do
  @moduledoc """
  Basic test helper for WiseHomex tests
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Quantity.Sigils, only: [sigil_d: 2, sigil_Q: 2]
    end
  end
end
