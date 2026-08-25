# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MAIS (Multi Agent Intelligent System) — distributed multi-agent security system. Agents discover each other on the local `/24` subnet via Java RMI (port 1099), exchange process reports using a SYN/ACK-inspired protocol, and enforce blacklist/whitelist policies through consensus-based voting.

## Build and test

```bash
mvn clean package        # compile + fat JAR (target/MAIS-<version>-jar-with-dependencies.jar)
mvn test                 # run tests (JaCoCo agent activates automatically)
mvn jacoco:report        # coverage report at target/site/jacoco/index.html (run tests first)
```

## Architecture

- Three concurrent threads via `ExecutorService`: network scan (5s), report broadcast (15s), policy enforcement (15s).
- `Agent` is the RMI remote interface; `DefaultAgent` is the abstract base; `SecurityAgent` is the concrete implementation.
- `Report` is `Serializable` — transmitted over RMI. Must stay serializable.
- Security policies live in `src/main/resources/blacklist.properties` and `whitelist.properties`.

## Conventions

- Java 1.8 source/target. Do not use Java 9+ features (modules, `var`).
- All production classes under `src/main/java/com/rios0rios0/`. Group ID: `com.rios0rios0`.
- Use `Console` and `Colorize` utilities for terminal output, not `System.out.println`.
- RMI remote interfaces extend `java.rmi.Remote`; all remote methods declare `throws RemoteException`.
- Tests use JUnit 4 (`@Test`, `@Before`, etc.) under `src/test/java/com/rios0rios0/`.
- Pin dependency versions in `pom.xml` — no version ranges.
- Commit conventions: [rios0rios0/guide/wiki](https://github.com/rios0rios0/guide/wiki).

## CI

GitHub Actions workflow (`default.yaml`) delegates to `rios0rios0/pipelines/.github/workflows/maven-library.yaml@main`. Includes OWASP Dependency-Check (requires `NVD_API_KEY` secret) and SonarCloud quality gate.

<!-- chlog:start -->
## Changelog (chlog) — MANDATORY

If the repository you are working in uses chlog (a `.chlog.yaml` or `.chlog.yml`
config file, or a `.changes/` directory, exists at the project root), the
following is binding and ALWAYS applies: whenever you make ANY change, you MUST
create a changelog fragment as part of the same change — automatically, without
being asked, before committing.

- Do NOT edit CHANGELOG.md directly; it is generated from fragments.
- Create the fragment with:
  `chlog new --kind <Kind> --body "<imperative description>"`
- Valid kinds: Added, Changed, Deprecated, Removed, Fixed, Security
- Choose the kind that best matches the change (e.g., new feature → Added,
  bug fix → Fixed, behavior change → Changed, removal → Removed, security fix → Security).
- If the change is backward-INCOMPATIBLE with the public API (a breaking
  change), you MUST add the `--breaking` flag:
  `chlog new --kind <Kind> --breaking --body "<description>"`.
  This is the ONLY thing that triggers a major version bump — the kind alone
  never does (per SemVer, major = incompatible change). When unsure whether a
  change breaks compatibility, ask the user instead of guessing.
- Fragments are YAML files in `.changes/unreleased/`; stage them with your commit.
- `chlog check` fails the build when a fragment is missing — never skip it.
<!-- chlog:end -->
