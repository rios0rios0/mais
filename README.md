<h1 align="center">MAIS - Multi Agent Intelligent System</h1>
<p align="center">
    <a href="https://github.com/rios0rios0/mais/releases/latest">
        <img src="https://img.shields.io/github/release/rios0rios0/mais.svg?style=for-the-badge&logo=github" alt="Latest Release"/></a>
    <a href="https://github.com/rios0rios0/mais/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/rios0rios0/mais.svg?style=for-the-badge&logo=github" alt="License"/></a>
</p>

A distributed multi-agent security system built with Java that monitors and enforces process-level security policies across networked machines. Agents communicate via Java RMI using a SYN/ACK-inspired protocol to share process execution reports, collectively deciding whether to start, kill, or escalate actions on blacklisted or whitelisted processes through consensus-based voting.

## Features

- **Distributed agent network** -- agents automatically discover each other by scanning the local subnet (all 254 addresses) and registering via Java RMI on the default registry port (1099)
- **SYN/ACK communication protocol** -- agents exchange `Report` objects containing hostname, IP address, timestamp, and a full snapshot of running processes, mimicking the TCP handshake pattern
- **Blacklist enforcement** -- processes listed in `blacklist.properties` are killed when detected; if a majority of neighbor agents are also running the blacklisted process, the system triggers a preventive device shutdown
- **Whitelist enforcement** -- processes listed in `whitelist.properties` are automatically started if not running; if a majority of neighbors report the process as absent, it is killed instead (consensus-based decision)
- **Singleton guarantee** -- each agent checks via RMI lookup that no other instance is already running on the same machine before starting
- **Concurrent architecture** -- three dedicated threads run in parallel via `ExecutorService`: network scanning (every 5 seconds), report broadcasting (every 15 seconds), and process action enforcement (every 15 seconds)
- **Colorized console output** -- ANSI-colored terminal output with SYN/ACK message indicators and status-level formatting (OK, FAIL, INFO)
- **Process management** -- uses the [jProcesses](https://github.com/profesorfalken/jProcesses) library for cross-platform process listing and killing

## Technologies

- Java 1.7 (SDK language level 7)
- [Maven](https://maven.apache.org/) with `maven-assembly-plugin` for fat JAR packaging
- [Java RMI](https://docs.oracle.com/javase/7/docs/technotes/guides/rmi/) for inter-agent communication
- [jProcesses](https://github.com/profesorfalken/jProcesses) 1.6.5 for cross-platform process inspection
- [JUnit](https://junit.org/junit4/) 4.13.1 for testing
- [JaCoCo](https://www.eclemma.org/jacoco/) for code coverage

## Project Structure

```
mais/
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
├── LICENSE
└── README.md
```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/rios0rios0/mais.git
   cd mais
   ```

2. Build with Maven:
   ```bash
   mvn clean package
   ```

## Usage

### Running the agent

```bash
java -jar target/MAIS-1.0.0-jar-with-dependencies.jar
```

The agent will:
1. Verify it is the only `MASAgent` instance on the machine
2. Detect the local hostname and IP address
3. Start the RMI registry on port 1099
4. Begin scanning the local subnet for other agents
5. Exchange process reports and enforce blacklist/whitelist policies

### Configuring policies

Edit the properties files under `src/main/resources/`:

**blacklist.properties** -- processes to kill:
```properties
# format: process_name=kill_command
ping=kill -9
sshd=kill -9
```

**whitelist.properties** -- processes to keep running:
```properties
# format: process_name=start_command;stop_command
apache2=apache2ctl start;apache2ctl stop
```

### How consensus works

When an agent detects a blacklisted process:
- If the majority of neighbor agents also have it running, the local machine is shut down as a preventive measure
- Otherwise, the process is killed locally

When an agent detects a whitelisted process is missing:
- If the majority of neighbors have it running, the process is started locally
- Otherwise, the process is killed (neighbors disagree it should be running)

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
