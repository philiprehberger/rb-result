# philiprehberger-result

[![Tests](https://github.com/philiprehberger/rb-result/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-result/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-result.svg)](https://rubygems.org/gems/philiprehberger-result)

Result type with Ok/Err, map, flat_map, and pattern matching for Ruby.

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-result"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install philiprehberger-result
```

## Usage

```ruby
require "philiprehberger/result"

# Create results
ok = Philiprehberger::Result.ok(42)
err = Philiprehberger::Result.err("not found")

ok.ok?   # => true
err.err? # => true
```

### Transformations

```ruby
result = Philiprehberger::Result.ok(5)

result.map { |v| v * 2 }          # => Ok(10)
result.flat_map { |v| Result.ok(v + 1) } # => Ok(6)

err = Philiprehberger::Result.err("bad input")
err.map { |v| v * 2 }             # => Err("bad input") (no-op)
err.map_err { |e| e.upcase }      # => Err("BAD INPUT")
```

### Unwrapping

```ruby
ok = Philiprehberger::Result.ok(42)
ok.unwrap!          # => 42
ok.unwrap_or(0)     # => 42

err = Philiprehberger::Result.err("fail")
err.unwrap_or(0)    # => 0
err.unwrap!         # raises UnwrapError
```

### Exception-safe wrapping

```ruby
result = Philiprehberger::Result.try { Integer("123") }
# => Ok(123)

result = Philiprehberger::Result.try { Integer("abc") }
# => Err(#<ArgumentError: invalid value for Integer(): "abc">)

# Catch specific exceptions
result = Philiprehberger::Result.try(IOError) { File.read("missing") }
```

### Pattern Matching

```ruby
case Philiprehberger::Result.ok(42)
in Philiprehberger::Result::Ok[value]
  puts "Success: #{value}"
in Philiprehberger::Result::Err[error]
  puts "Error: #{error}"
end
```

## API

| Method / Class | Description |
|----------------|-------------|
| `Result.ok(value)` | Create a success result |
| `Result.err(error)` | Create a failure result |
| `Result.try(*exceptions, &block)` | Wrap a block, capturing exceptions as Err |
| `Ok#map { \|v\| ... }` | Transform the success value |
| `Ok#flat_map { \|v\| ... }` | Chain a result-returning operation |
| `Ok#unwrap!` | Return the value |
| `Ok#unwrap_or(default)` | Return the value (ignores default) |
| `Err#map_err { \|e\| ... }` | Transform the error value |
| `Err#unwrap!` | Raise UnwrapError |
| `Err#unwrap_or(default)` | Return the default |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
