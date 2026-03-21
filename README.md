# philiprehberger-result

[![Tests](https://github.com/philiprehberger/rb-result/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-result/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-result.svg)](https://rubygems.org/gems/philiprehberger-result)
[![License](https://img.shields.io/github/license/philiprehberger/rb-result)](LICENSE)

Result type with Ok/Err, map, flat_map, filter, tap, and pattern matching for Ruby.

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-result"
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

### Side Effects

```ruby
# Execute a side-effect on Ok without changing the result
Philiprehberger::Result.ok(42)
  .tap_ok { |v| puts "Got value: #{v}" }
  .map { |v| v * 2 }
# prints "Got value: 42", returns Ok(84)

# Execute a side-effect on Err without changing the result
Philiprehberger::Result.err("fail")
  .tap_err { |e| logger.error(e) }
  .or_else { |e| Philiprehberger::Result.ok("default") }
# logs "fail", returns Ok("default")
```

### Filtering

```ruby
result = Philiprehberger::Result.ok(5)

# Convert Ok to Err when predicate fails
result.filter(-> { "must be negative" }) { |v| v < 0 }
# => Err("must be negative")

result.filter(-> { "must be positive" }) { |v| v > 0 }
# => Ok(5)

# Err passes through unchanged
Philiprehberger::Result.err("already failed")
  .filter(-> { "unused" }) { |v| v > 0 }
# => Err("already failed")
```

### Combining Results

```ruby
ok1 = Philiprehberger::Result.ok(1)
ok2 = Philiprehberger::Result.ok(2)
err = Philiprehberger::Result.err("fail")

Philiprehberger::Result.all([ok1, ok2])
# => Ok([1, 2])

Philiprehberger::Result.all([ok1, err, ok2])
# => Err("fail")
```

### Error Recovery

```ruby
result = Philiprehberger::Result.err("not found")

# Recover with or_else
recovered = result.or_else { |e| Philiprehberger::Result.ok("default") }
# => Ok("default")

# Chain with and_then (alias for flat_map)
Philiprehberger::Result.ok(5)
  .and_then { |v| Philiprehberger::Result.ok(v * 2) }
  .and_then { |v| Philiprehberger::Result.ok(v + 1) }
# => Ok(11)
```

### Serialization

```ruby
Philiprehberger::Result.ok(42).to_h    # => { ok: 42 }
Philiprehberger::Result.err("fail").to_h # => { err: "fail" }
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
| `Result.all(results)` | Combine results: Ok with values array, or first Err |
| `Ok#map { \|v\| ... }` | Transform the success value |
| `Ok#flat_map { \|v\| ... }` | Chain a result-returning operation |
| `Ok#unwrap!` | Return the value |
| `Ok#unwrap_or(default)` | Return the value (ignores default) |
| `#tap_ok { \|v\| ... }` | Side-effect on Ok value, returns self |
| `#tap_err { \|e\| ... }` | Side-effect on Err value, returns self |
| `#filter(error_fn) { \|v\| ... }` | Convert Ok to Err if predicate fails |
| `Err#map_err { \|e\| ... }` | Transform the error value |
| `Err#unwrap!` | Raise UnwrapError |
| `Err#unwrap_or(default)` | Return the default |
| `Ok#or_else { \|e\| ... }` | Return self (no-op on Ok) |
| `Err#or_else { \|e\| ... }` | Call block with error for recovery |
| `#and_then { \|v\| ... }` | Alias for `flat_map` |
| `#to_h` | Serialize to `{ ok: value }` or `{ err: error }` |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
