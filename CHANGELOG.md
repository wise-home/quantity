# Changelog

## 0.6.1 - 2020-12-16

### Enhancements:

* Add integer option as the second param to div and mult

### Deps updates (no runtime deps here):

* Update credo 1.4.0 -> 1.5.3
* Update erlang 23.0.4 -> 23.2
* Update earmark_parser 1.4.10 -> 1.4.12
* Update file_system 0.2.9 -> 0.2.10
* Update elixir 1.10.4 -> 1.11.2
* Update ex_doc 0.22.6 -> 0.23.0
* Update makeup_elixir 0.14.1 -> 0.15.0
* Update makeup 1.0.3 -> 1.0.5, nimble_parsec 0.6.0 -> 1.1.0

## 0.6.0 - 2020-09-29

* Update decimal 1.9.0 -> 2.0.0, 31

## 0.5.3 - 2020-09-21

* Fix required Decimal version in mix.exs
* Fix wrong jason version specified in CHANGELOG for version 0.5.2

## 0.5.2 - 2020-09-21

Code changes:

* Change Decimal.reduce -> Decimal.normalize (the functions are identical), 29

Dependency changes:

* Update decimal to 1.9.0, 29
* Update ex_doc to 0.22.6, 29
* Update to credo 1.4.0, 24
* Update to earmark 1.4.10, 27
* Update to elixir 1.4.10, 27
* Update to erlang 23.0.4, 29
* Update to jason 1.2.2, 29
* Speed up testing on GitHub Actions

## 0.5.1 - 2020-04-07

* Fix type spec of unit to be recursive

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
