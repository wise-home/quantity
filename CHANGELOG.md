# Changelog


## 0.5.0 - 2020-04-07

**Backwards incompatibility**: With the introduction of a `1` unit, `Quantity.div/2` now always returns a Quantity,
also when the result is a scalar. In that case it will be a Quantity with the unit `1`.

* Add support for arbitrary complex units
* Added to_decimal/1 convinience function
* Generalize reduce_unit/1
* Introduce `1` unit
* Add Quantity.inverse/1
* Update makeup 1.0.0 -> 1.0.1
* Update credo 1.3.1 -> 1.3.2

## 0.4.0 - 2020-03-24

* `compare/2` (only for same unit)
* `equals?/2` and reduce/1
* `convert_unit/3` helper function
* Extracted `decimal_to_string/1` to own public function
* Update erlang 22.2.8 -> 22.3
* Update credo 1.3.0 -> 1.3.1
* Update jason 1.1.2 -> 1.2.0
* Update dialyxir 1.0.0-rc.7 -> 1.0.0

## 0.3.1 - 2020-03-12

* Add to_zero function, 12

## 0.3.0 - 2020-01-21

* Div, mult and more features, 8

## 0.2.0 - 2020-01-20

* Add basic math functions, 1
* Update README.md with instructions for basic bath functions, 5
* Setup CI, 3

## 0.1.0 - 2020-01-17

* Initial release
