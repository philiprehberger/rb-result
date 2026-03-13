# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-03-12

### Fixed
- Re-release with no code changes (RubyGems publish fix)

## [0.2.0] - 2026-03-12

### Added
- `or_else` method on Ok and Err for error recovery chains
- `and_then` alias for `flat_map` (Rust/functional convention)
- `to_h` method on Ok and Err for hash serialization
- Tests for method chaining and multi-exception `Result.try`

## [0.1.0] - 2026-03-10

### Added
- Initial release
- `Ok` and `Err` result types
- `map`, `flat_map`, `map_err` transformations
- `unwrap!` and `unwrap_or` value extraction
- `Result.try` for exception-safe wrapping
- Ruby 3.1+ pattern matching support (`deconstruct`, `deconstruct_keys`)
