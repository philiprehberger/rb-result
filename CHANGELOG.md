# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.3] - 2026-03-24

### Fixed
- Fix README one-liner to remove trailing period and match gemspec summary

## [0.3.2] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.3.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

## [0.3.1] - 2026-03-21

### Fixed
- Standardize Installation section in README

## [0.3.0] - 2026-03-17

### Added
- `tap_ok` method for executing side-effects on Ok values without changing the result
- `tap_err` method for executing side-effects on Err values without changing the result
- `filter` method to convert Ok to Err when a predicate fails
- `Result.all` class method to combine an array of results into a single result
- `Tappable` module extracting tap_ok/tap_err for rubocop class length compliance
- `Filterable` module extracting filter for rubocop class length compliance

## [0.2.2] - 2026-03-16

### Fixed
- Add License badge to README
- Add bug_tracker_uri to gemspec

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
