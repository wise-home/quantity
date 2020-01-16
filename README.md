# Quantity

A `Quantity` is a data structure that encapsulates values with units. This data structure can be used to carry values and units through calculations using the calculation functions in the Quantity library.

## Usage

#### Creating Quantities

A `Quantity` can be created in several ways, one is `Quantity.parse/1` or `Quantity.parse!/1`, which parses a Quantity from a string:

```elixir
Quantity.parse("200.345 EUR")
# {:ok, ~Q[200.345 EUR]}

Quantity.parse!("200.345 EUR")
# ~Q[200.345 EUR]
```

The `Quantity` module also has `new/2` which creates a `Quantity` from a `Decimal.t()` and a `String.t()`:

```elixir
Quantity.new(Decimal.new("300.445"), "km")
# ~Q[300.445 km]
```

And lastly a `Quantity` can be created from a value, an exponent and a unit:

```elixir
Quantity.new(6578, -2, "seconds")
# ~Q[65.78 seconds]
```

#### The ~Q and ~d helpers

`Quantity` has a special `sigil_Q/2` helper and therefore the `~Q` notation as seen above. We can create them using the `~Q` helper, and they are printed the same way when inspected.

```elixir
import Quantity.Helpers, only: [sigil_Q: 2]

~Q[500 bananas]
# ~Q[500 bananas]
```

Additionally a `sigil_d/2` helpers is also present to easily create decimals:

```elixir
import Quantity.Helpers, only: [sigil_d: 2]

~d[123.456]
#Decimal<123.456>
```

#### Data structure

Underneath, a `Quantity` is simply a map consisting of `value` and `unit`, where `value` is a `Decimal.t()` and `unit` a `String.t()`:

```elixir
~Q[99 problems] |> IO.inspect(structs: false)
%{
  __struct__: Quantity,
  unit: "problems",
  value: %{__struct__: Decimal, coef: 99, exp: 0, sign: 1}
}
```


## Installation

The package is only available on GitHub at the moment, it can be added to `mix.exs` using:

```elixir
def deps do
  [
    # Add Quantity from GitHub
    {:quantity, git: "https://github.com/wise-home/quantity.git", tag: "0.1.0"}
  ]
end
```

