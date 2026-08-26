# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file is not edited by hand. Every change writes its own fragment under
`.changes/unreleased/` with [chlog](https://github.com/luizjhonata/chlog), and a release compiles
the pending fragments into a version section here — so two branches each adding an entry no
longer touch the same lines, and a rebase that used to conflict on this file now conflicts on
nothing.

When a new release is proposed:

1. Create a new branch `bump/x.x.x` (this isn't a long-lived branch!!!);
2. The fragments pending under `.changes/unreleased/` are compiled into a version section by `chlog batch auto && chlog merge` (AutoBump does this for you — it reads the fragments directly);
3. Open a Pull Request with the bump version changes targeting the `main` branch;
4. When the Pull Request is merged, a new Git tag must be created using [GitHub environment](https://github.com/rios0rios0/mais/tags).

Releases to productive environments should run from a tagged version.
Exceptions are acceptable depending on the circumstances (critical bug fixes that can be cherry-picked, etc.).

## [Unreleased]

## [0.3.0] - 2026-08-26

### Added

- added a tailored `code-review` skill under `.github/skills/` so GitHub Copilot reviews changes against the [rios0rios0/guide](https://github.com/rios0rios0/guide/wiki) standards and this repository's own load-bearing invariants

### Changed

- changed the changelog to [chlog](https://github.com/luizjhonata/chlog) fragments: a change now writes its own YAML file under `.changes/unreleased/` through `chlog new --kind <Kind> --body "..."`, and `CHANGELOG.md` is GENERATED from them at release time by `chlog batch auto && chlog merge`. That is the one thing a single shared file cannot do — two branches each adding an entry no longer touch the same lines, so a rebase that used to conflict on `CHANGELOG.md` now conflicts on nothing. The `[Unreleased]` section was empty, so nothing had to be carried across. AutoBump already reads the fragments directly, so the release flow is unchanged.

### Fixed

- fixed the `code-check > quality:proguard` job, which failed on every run against `main`. ProGuard listed five dead members; exactly one of them was really dead -- the `Colorize.setColor(String, Params)` overload, which no caller anywhere reached -- and it has been deleted. The other four are artefacts of ProGuard reading BYTECODE rather than source: `SecurityAgent.SERVICE_NAME`, `SecurityAgent.CONNECTION_TIMEOUT` and `Commands.SUDO_PASSWD` are compile-time constants that javac folds into each use site, so the fields are never read with `getstatic` even though the source uses them throughout, and `Report.serialVersionUID` is read reflectively by Java serialization, which no call graph can see. A new `.proguard-keep.pro` exempts those four by exact name, so any newly unused member is still reported.
- fixed the `main` pipeline, which every repository's `sast:gitleaks` job had been failing since the code-review skill landed: the skill's own security bullet listed credential prefixes verbatim to warn against writing them, and the scanner's second pass matches those prefixes on their own, so the warning tripped the rule it was describing. The bullet now names the vendors instead, and the commit that carried the original wording is allowlisted by fingerprint in `.gitleaksignore`, because the scan walks the whole history reachable from `HEAD` and no edit at the tip can clear a past commit. No credential was ever committed.

## [0.2.1] - 2026-05-19

### Changed

- refreshed `CLAUDE.md` and `.github/copilot-instructions.md` to reference the renamed CI workflow (`maven-library.yaml`, was `java-maven.yaml`)

## [0.2.0] - 2026-04-28

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
