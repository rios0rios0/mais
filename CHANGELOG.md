# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

When a new release is proposed:

1. Create a new branch `bump/x.x.x` (this isn't a long-lived branch!!!);
2. The Unreleased section on `CHANGELOG.md` gets a version number and date;
3. Open a Pull Request with the bump version changes targeting the `main` branch;
4. When the Pull Request is merged, a new Git tag must be created using [GitHub environment](https://github.com/rios0rios0/mais/tags).

Releases to productive environments should run from a tagged version.
Exceptions are acceptable depending on the circumstances (critical bug fixes that can be cherry-picked, etc.).

## [Unreleased]

### Added

- added `CLAUDE.md` with build commands, architecture overview, and repo conventions for Claude Code sessions

### Changed

- refreshed `.github/copilot-instructions.md` to reflect Java 1.8 (was 1.7), JUnit 4.13.2 (was 4.13.1), current artifact version, and OWASP Dependency-Check plugin

## [0.1.1] - 2026-04-15

### Changed

- changed the Java dependencies to their latest versions

## [0.1.0] - 2026-03-12

### Added

- added GitHub Actions workflow for CI/CD pipeline
- added OWASP Dependency-Check Maven plugin configuration with NVD API key support to fix CI database corruption from rate-limited NVD requests

### Fixed

- fixed JVM crash during test execution by updating JaCoCo (`0.8.12`), Surefire (`3.5.2`), and Coveralls (`4.4.0`) plugin versions for Java 21 compatibility

### Removed

- removed Travis CI configuration in favor of GitHub Actions
