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
