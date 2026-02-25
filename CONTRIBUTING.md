# Contributing

Contributions are welcome. By participating, you agree to maintain a respectful and constructive environment.

For coding standards, testing patterns, architecture guidelines, commit conventions, and all
development practices, refer to the **[Development Guide](https://github.com/rios0rios0/guide/wiki)**.

## Prerequisites

- [JDK](https://adoptium.net/) 8+
- [Maven](https://maven.apache.org/) 3+

## Development Workflow

1. Fork and clone the repository
2. Create a branch: `git checkout -b feat/my-change`
3. Build the project:
   ```bash
   mvn clean install
   ```
4. Make your changes
5. Run tests:
   ```bash
   mvn test
   ```
6. Commit following the [commit conventions](https://github.com/rios0rios0/guide/wiki/Life-Cycle/Git-Flow)
7. Open a pull request against `main`
