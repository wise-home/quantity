# Quantity

![](https://github.com/wise-home/quantity/workflows/CI/badge.svg)

A `Quantity` is an Elixir data structure that encapsulates values with units. This data structure can be used to carry values and units through calculations using the calculation functions in the Quantity library.

```elixir
~Q[200.345 kWh] |> Quantity.add(~Q[249.23 kWh])
# {:ok, ~Q[449.575 kWh]}

[
  ~Q[13.49 second],
  ~Q[12.39 second],
  ~Q[4.49 second]
]
|> Quantity.sum()
# {:ok, ~Q[30.37 second]}

cost = ~Q[0.40 $/banana]
amount = ~Q[2000 banana]
Quantity.mult(cost, amount)
# ~Q[800.00 $]
```

## Usage

#### Creating Quantities

A `Quantity` can be created in several ways, one is `Quantity.parse/1` or `Quantity.parse!/1`, which parses a Quantity from a string:

```elixir
Quantity.parse("200.345 EUR")
# {:ok, ~Q[200.345 EUR]}

Quantity.parse!("200.345 EUR")
# ~Q[200.345 EUR]

Quantity.parse!("20.67 EUR/beer")
# ~Q[20.67 EUR/beer] or the same as
# Quantity.new(~d[20.67], {:div, "EUR", "beer"})

Quantity.parse!("15.0 m*m")
# ~Q[15.0 m*m] or the same as
# Quantity.new(~d[15.0], {:mult, "m", "m"})
```

The `Quantity` module also has `new/2` which creates a `Quantity` from a `Decimal.t()` and a `String.t()`:

```elixir
Quantity.new(Decimal.new("300.445"), "km")
# ~Q[300.445 km]
```

And lastly a `Quantity` can be created from a value, an exponent and a unit:

```elixir
Quantity.new(6578, -2, "second")
# ~Q[65.78 second]
```

#### Addition and subtraction

Basic math can be done using the `add/2` and `sub/2` functions along with their `add!/2` and `sub!/2` siblings:

```elixir
Quantity.add(~Q[500 mL coffee], ~Q[250 mL coffee])
# {:ok, ~Q[750 mL coffee]}

Quantity.add!(~Q[500 mL coffee], ~Q[250 mL coffee])
# ~Q[750 mL coffee]

Quantity.sub(~Q[250 gram], ~Q[125 gram])
# {:ok, ~Q[125 gram]}

Quantity.sub!(~Q[250 gram], ~Q[125 gram])
# ~Q[125 gram]
```

#### Summation

To sum non-empty lists with identical units, `sum/1` and `sum!/1` can be used:

```elixir
lap_times = [
  ~Q[4.24 second],
  ~Q[4.59 second],
  ~Q[5.22 second],
  ~Q[3.99 second]
]

lap_times |> Quantity.sum()
# {:ok, ~Q[18.04 second]}

lap_times |> Quantity.sum!()
# ~Q[18.04 second]

[] |> Quantity.sum()
# :error
```

When a list is empty, `Quantity` doesn't know what precision and unit the result should have. If a `Quantity` with value 0 is desired when summing an empty list, one can use `sum/3` and `sum!/3`:

```elixir
sales_2018 = []

sales_2019 = [
  ~Q[1234.39 EUR],
  ~Q[228.50 EUR]
]

sales_2018 |> Quantity.sum(-2, "EUR")
# {:ok, ~Q[0.00 EUR]}

sales_2019 |> Quantity.sum(-2, "EUR")
# {:ok, ~Q[1462.89 EUR]}
```

#### Multiplication and division

Quantity has support for single-level complex units that are divided or multiplied:

```elixir
cost = ~Q[20.00 $]
amount = ~Q[50 banana]
cost_per_banana = Quantity.div(cost, amount)
# ~Q[0.40 $/banana]

new_amount = ~Q[2000 banana]
Quantity.mult(cost_per_banana, new_amount)
# ~Q[800.00 $]

Quantity.mult(~Q[5 m], ~Q[4.3 m])
# ~Q[21.5 m*m]

Quantity.mult(~Q[5 m], ~d[20.01])
# ~Q[100.05 m]
```

#### The ~Q and ~d sigils

`Quantity` has a special `sigil_Q/2` sigil, as seen above. Quantities can be created using the `~Q` sigil, and they are printed as `~Q` when inspected.

```elixir
import Quantity.Sigils, only: [sigil_Q: 2]

~Q[500 bananas]
# ~Q[500 bananas]

# Supports :mult and :div units
~Q[0.54 $/banana]
~Q[13.2 m*m]

```

Additionally a `sigil_d/2` sigil is also present to easily create decimals:

```elixir
import Quantity.Sigils, only: [sigil_d: 2]

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


## Versions of Elixir and Erlang

Quantity will be tested against the two latest minor versions of Elixir (but >= 1.9) and the three latest minor versions of Erlang. In all cases the latest patch version is used.

E.g. if the latest Elixir is 1.10.2 and the latest Erlang is 22.3, we test against:

    Elixir: 1.9.4, 1.10.2
    Erlang: 22.1.8.1, 22.2.8 and 22.3
