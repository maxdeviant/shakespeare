# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fixed a crash when starting the `ScheduledActor` with a `Weekly` schedule set for earlier that same day.

## [0.1.2] - 2024-04-27

### Added

- Added `Weekly` schedule for `ScheduledActor`.

## [0.1.1] - 2024-04-14

### Fixed

- Fixed a bug where `PeriodicActor` would spawn two copies of itself.

## [0.1.0] - 2024-04-11

- Initial release.

[unreleased]: https://github.com/maxdeviant/shakespeare/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/maxdeviant/shakespeare/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/maxdeviant/shakespeare/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/maxdeviant/shakespeare/compare/a1b5ab4...v0.1.0
