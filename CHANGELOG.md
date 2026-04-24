# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-04-23

### Added
- `#unwrap_or_else(&block)` on Ok (returns the value) and Err (yields the error to the block and returns its result) — lets a fallback be computed from the error, complementing `unwrap_or(default)`

## [0.6.0] - 2026-04-15

### Added
- `#to_maybe` method on Ok (returns value) and Err (returns nil) for Maybe-style extraction
- `#contains?(value)` predicate to test whether an Ok holds a specific value
- `#contains_err?(error)` predicate to test whether an Err holds a specific error
- `Result.partition(results)` class method splitting an array of results into `[ok_values, err_values]`

## [0.5.0] - 2026-04-12

### Added
- `unwrap_err!` method on Ok (raises) and Err (returns error) for symmetric unwrapping
- `Result.flatten(result)` class method to flatten nested Result types
- `map_or(default, &block)` method to map with a fallback for Err

### Fixed
- Fix duplicate `[0.3.1]` entry in CHANGELOG

## [0.4.0] - 2026-04-01

### Added
- `Result.any(results)` returning first Ok or Err with all errors
- `#zip(other)` for combining two Ok results into `Ok([a, b])`
- `#recover(error_class)` for typed error recovery on Err

## [0.3.7] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.3.6] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.3.5] - 2026-03-26

### Changed

- Add Sponsor badge and fix License link format in README

## [0.3.4] - 2026-03-24

### Changed
- Expand test coverage to 65+ examples covering edge cases and error paths

## [0.3.3] - 2026-03-24

### Fixed
- Fix README one-liner to remove trailing period and match gemspec summary

## [0.3.2] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.3.1] - 2026-03-22

### Changed
- Update rubocop configuration for Windows compatibility

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

[Unreleased]: https://github.com/philiprehberger/rb-result/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/philiprehberger/rb-result/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/philiprehberger/rb-result/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/philiprehberger/rb-result/compare/v0.3.7...v0.4.0
[0.3.7]: https://github.com/philiprehberger/rb-result/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/philiprehberger/rb-result/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/philiprehberger/rb-result/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/philiprehberger/rb-result/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/philiprehberger/rb-result/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/philiprehberger/rb-result/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/philiprehberger/rb-result/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/philiprehberger/rb-result/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/philiprehberger/rb-result/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/philiprehberger/rb-result/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/philiprehberger/rb-result/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/philiprehberger/rb-result/releases/tag/v0.1.0
