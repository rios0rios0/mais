# Copilot Instructions for MAIS

## Project Overview

MAIS (Multi Agent Intelligent System) is a distributed, multi-agent security system built with Java 1.8.
It monitors and enforces process-level security policies across networked machines.
Agents communicate via Java RMI using a SYN/ACK-inspired protocol, sharing process execution reports and collectively deciding whether to start, kill, or escalate actions on blacklisted or whitelisted processes through consensus-based voting.

## Technology Stack

- **Language**: Java 1.8 (SDK language level 8)
- **Build tool**: Apache Maven 3.6+ with `maven-assembly-plugin` for fat JAR packaging
- **RMI**: Java RMI on port 1099 for inter-agent communication
- **Process management**: [jProcesses](https://github.com/profesorfalken/jProcesses) 1.6.5
- **Testing**: JUnit 4.13.2
- **Coverage**: JaCoCo with Coveralls integration
- **CI/CD**: GitHub Actions via a reusable workflow (`rios0rios0/pipelines/.github/workflows/java-maven.yaml@main`)
- **Code quality**: SonarCloud
- **Security scanning**: OWASP Dependency-Check Maven plugin (configured with NVD API key)

## Repository Structure

```
mais/
├── .github/
│   ├── copilot-instructions.md   # This file
│   └── workflows/
│       └── default.yaml          # CI/CD pipeline (delegates to shared pipelines repo)
├── src/
│   ├── main/
│   │   ├── java/com/rios0rios0/
│   │   │   ├── Main.java                  # Entry point - bootstraps the SecurityAgent
│   │   │   ├── actions/
│   │   │   │   └── TargetsList.java        # Loads blacklist/whitelist from .properties files
│   │   │   ├── engine/
│   │   │   │   ├── Agent.java              # RMI remote interface (syn/ack methods)
│   │   │   │   ├── DefaultAgent.java       # Abstract base agent class
│   │   │   │   └── SecurityAgent.java      # Core agent: scanning, reporting, enforcement
│   │   │   ├── info/
│   │   │   │   └── Report.java             # Serializable report (host, processes, timestamp)
│   │   │   └── utils/
│   │   │       ├── Colorize.java           # ANSI terminal color formatting
│   │   │       ├── Commands.java           # Shell command execution with sudo
│   │   │       └── Console.java            # Formatted console output (SYN/ACK/OK/FAIL)
│   │   └── resources/
│   │       ├── blacklist.properties        # Processes to kill (e.g., ping, sshd)
│   │       └── whitelist.properties        # Processes to keep alive (e.g., apache2)
│   └── test/java/com/rios0rios0/
│       └── MainTest.java
├── pom.xml
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Build, Test, and Run Commands

All commands are run from the repository root.

| Task | Command | Notes |
|------|---------|-------|
| Build fat JAR | `mvn clean package` | Output: `target/MAIS-<version>-jar-with-dependencies.jar` |
| Run tests | `mvn test` | JaCoCo agent is activated automatically |
| Generate coverage report | `mvn jacoco:report` | Report at `target/site/jacoco/index.html` |
| Run the agent | `java -jar target/MAIS-<version>-jar-with-dependencies.jar` | Requires Java 1.8+ |

Build time is typically under 60 seconds on a standard machine. Tests run in under 30 seconds.

## Architecture and Design Patterns

- **Distributed agents**: Each running instance is both a server and a client; agents discover each other by scanning the local `/24` subnet on port 1099.
- **SYN/ACK protocol**: Agents exchange `Report` objects (hostname, IP, timestamp, process list) in a handshake-like pattern via the `Agent` RMI interface.
- **Consensus-based enforcement**: Decisions to kill or start a process are taken by majority vote among all discovered neighbor agents.
- **Singleton check**: On startup, each agent uses RMI lookup to ensure no other `MASAgent` instance is running on the same host.
- **Concurrent threading**: Three threads run via `ExecutorService`:
  1. Network scan — every 5 seconds
  2. Report broadcast — every 15 seconds
  3. Policy enforcement — every 15 seconds

## Configuration

Security policies are stored as `.properties` files under `src/main/resources/`:

**`blacklist.properties`** — processes to kill when detected:
```properties
# format: process_name=kill_command
ping=kill -9
sshd=kill -9
```

**`whitelist.properties`** — processes that must stay running:
```properties
# format: process_name=start_command;stop_command
apache2=apache2ctl start;apache2ctl stop
```

## CI/CD Pipeline

The GitHub Actions workflow (`default.yaml`) delegates to the shared reusable workflow at `rios0rios0/pipelines/.github/workflows/java-maven.yaml@main`.

It runs on:
- Pushes to `main`
- Any tag push
- Pull requests targeting `main`
- Manual dispatch (`workflow_dispatch`)

Required permissions: `security-events: write`, `contents: write`.

## Development Workflow

1. Fork and clone the repository.
2. Create a feature branch: `git checkout -b feat/my-change`
3. Make changes and build: `mvn clean package`
4. Run tests: `mvn test`
5. Verify coverage: `mvn jacoco:report`
6. Follow the commit conventions documented at [rios0rios0/guide/wiki](https://github.com/rios0rios0/guide/wiki).
7. Open a pull request against `main`.

## Coding Conventions

- Java 1.8 source and target compatibility — do **not** use Java 9+ language features (modules, `var`, etc.). Lambdas and streams are permitted.
- Group ID: `com.rios0rios0`; keep all production classes under `src/main/java/com/rios0rios0/`.
- Use the `Console` and `Colorize` utilities for all terminal output rather than `System.out.println`.
- RMI remote interfaces must extend `java.rmi.Remote`; all remote methods must declare `throws RemoteException`.
- `Report` must remain `Serializable` (it is transmitted over RMI).
- Tests live under `src/test/java/com/rios0rios0/`; use JUnit 4 annotations (`@Test`, `@Before`, etc.).
- Keep `pom.xml` dependency versions pinned — do not use version ranges.
- Coding standards, testing patterns, and architectural guidelines are maintained in the [Development Guide](https://github.com/rios0rios0/guide/wiki).

## Common Tasks and Troubleshooting

### Port 1099 already in use
Another RMI registry is running. Stop it or run the agent on a different host. The singleton check will also prevent two agents from running on the same machine.

### Agent cannot find neighbours
Ensure the hosts are on the same `/24` subnet and that port 1099 is not blocked by a firewall.

### Build fails with "source/target 1.8" errors
Verify your JDK is 1.8 or later. The Maven compiler source/target is explicitly set to `1.8` in `pom.xml`.

### Coverage report is empty
Run `mvn test` before `mvn jacoco:report` — the JaCoCo agent must instrument the test run first.
