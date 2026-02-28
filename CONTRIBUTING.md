# Contributing

Contributions are welcome. By participating, you agree to maintain a respectful and constructive environment.

For coding standards, testing patterns, architecture guidelines, commit conventions, and all
development practices, refer to the **[Development Guide](https://github.com/rios0rios0/guide/wiki)**.

## Prerequisites

- [Java JDK](https://www.oracle.com/java/technologies/javase-downloads.html) v1.7+
- [Apache Maven](https://maven.apache.org/download.cgi) v3.6+

## Development Workflow

1. Fork and clone the repository
2. Create a branch: `git checkout -b feat/my-change`
3. Build the project and generate the fat JAR:
   ```bash
   mvn clean package
   ```
4. Run tests with JaCoCo coverage:
   ```bash
   mvn test
   ```
5. Generate the coverage report:
   ```bash
   mvn jacoco:report
   ```
   The report will be available at `target/site/jacoco/index.html`.
6. Run the agent:
   ```bash
   java -jar target/MAIS-1.0.0-jar-with-dependencies.jar
   ```
7. Configure security policies by editing the properties files under `src/main/resources/`:
   - `blacklist.properties` -- processes to kill when detected
   - `whitelist.properties` -- processes to keep running
8. Commit following the [commit conventions](https://github.com/rios0rios0/guide/wiki/Life-Cycle/Git-Flow)
9. Open a pull request against `main`
