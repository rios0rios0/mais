---
name: code-review
description: "Review pull requests and diffs in mais — the Multi Agent Intelligent System research project in Java with RMI — against the rios0rios0/guide standards, with extra weight on the consensus protocol, RMI and subnet-scanning safety, and process-killing side effects. Use when reviewing a PR, a branch, or staged changes here."
---

# Code review — `mais`

`mais` runs one agent per host that is both an RMI server and client: agents discover each other by scanning the local `/24` on port 1099, exchange `Report` objects in a SYN/ACK handshake, and decide by majority vote whether to kill or start a process. It executes shell commands with `sudo`, so the enforcement path is the review's centre of gravity.

## When to use this skill

Use it whenever you are asked to review a pull request, a diff, a branch, or staged changes
in this repository — and before opening a pull request of your own, as a self-check. It is a
**review** skill: it produces findings, not commits.

## Source of truth

The canonical engineering standards live in the
**[rios0rios0/guide wiki](https://github.com/rios0rios0/guide/wiki)**. This file is a
repo-tailored index into that guide plus the rules that only apply here. Precedence, highest
first:

1. This repository's `.github/copilot-instructions.md`, `CLAUDE.md`, and `CONTRIBUTING.md` —
   they describe *this* codebase and its load-bearing invariants.
2. The **rios0rios0/guide** wiki — the shared standard.
3. General language idiom.

When the guide and a general convention disagree, the guide wins. When this file and the
guide disagree, the guide wins and this file should be corrected in the same pull request.

### Guide pages that apply here

| Topic | Page |
|-------|------|
| Java — overview, Liquibase, design principles | [Java](https://github.com/rios0rios0/guide/wiki/Java) |
| Java Conventions — `<Operation><Entity>` naming, entities, mappers | [Java-Conventions](https://github.com/rios0rios0/guide/wiki/Java-Conventions) |
| Java Formatting and Linting — Spotless, Checkstyle, PMD, SpotBugs | [Java-Formatting-and-Linting](https://github.com/rios0rios0/guide/wiki/Java-Formatting-and-Linting) |
| Java Type System — records, generics, sealed classes | [Java-Type-System](https://github.com/rios0rios0/guide/wiki/Java-Type-System) |
| Java Logging — SLF4J with `{}` placeholders | [Java-Logging](https://github.com/rios0rios0/guide/wiki/Java-Logging) |
| Java Testing — JUnit 5, BDD blocks | [Java-Testing](https://github.com/rios0rios0/guide/wiki/Java-Testing) |
| Java Project Structure | [Java-Project-Structure](https://github.com/rios0rios0/guide/wiki/Java-Project-Structure) |
| Architecture — Clean Architecture and SOLID | [Architecture](https://github.com/rios0rios0/guide/wiki/Architecture) |
| Tests — BDD structure, description patterns, test doubles | [Tests](https://github.com/rios0rios0/guide/wiki/Tests) |
| Mapper Design Pattern — replacing `switch`/`case` | [Mapper-Design-Pattern](https://github.com/rios0rios0/guide/wiki/Mapper-Design-Pattern) |
| Git Flow — branches, commits, SemVer, breaking changes | [Git-Flow](https://github.com/rios0rios0/guide/wiki/Git-Flow) |
| Documentation & Change Control — changelog and docs discipline | [Documentation-&-Change-Control](https://github.com/rios0rios0/guide/wiki/Documentation-&-Change-Control) |
| CHANGELOG Formatting — capitalisation and backticks | [CHANGELOG-Formatting](https://github.com/rios0rios0/guide/wiki/CHANGELOG-Formatting) |
| Security — OWASP checklist, secret hygiene, SAST | [Security](https://github.com/rios0rios0/guide/wiki/Security) |
| CI & CD — pipeline stages and the local quality gates | [CI-&-CD](https://github.com/rios0rios0/guide/wiki/CI-&-CD) |
| Code Style — baseline naming and the operations vocabulary | [Code-Style](https://github.com/rios0rios0/guide/wiki/Code-Style) |

## How to run the review

1. **Establish the range.** Resolve the default branch with
   `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/`; fall back to `main`),
   then read the diff with `git diff <default>...HEAD` and the file list with
   `git diff <default>...HEAD --name-only`.
2. **Read whole files, not just hunks.** A hunk cannot show a layering violation, a missing
   test, or a duplicated helper. Open every changed file in full, plus the files it imports
   from the layer below.
3. **Check the change set as a unit** — not only the code. A change that alters behaviour,
   configuration, or architecture is incomplete without its changelog entry and its
   documentation update, and that omission is a finding in its own right.
4. **Map every finding to a rule.** Each finding must name the rule it breaks and link the
   guide page (or the repository file) that states it. A comment that cannot be traced to a
   rule is a suggestion, not a defect — label it as such.
5. **Report, do not rewrite.** Produce the review in the output format below. Only edit files
   when the request explicitly asks for fixes.

## What matters most in `mais`

These are the checks that catch real defects in this repository. Work through
them before the generic ones.

- **Enforcement runs shell commands with `sudo`.** Anything reaching `Commands` must be validated against the blacklist/whitelist — never built from a value received over RMI. A remotely-influenced string in a `sudo` command is a **Critical** finding.
- **Java RMI deserialises whatever it is sent.** `Report` crosses the wire; treat every field as untrusted, and reject any change that widens what may be deserialised or that adds a new remote method without validating its arguments.
- **Consensus must survive partial failure.** A kill or start decision is a majority vote among discovered neighbours. Check what happens with zero neighbours, an even split, and a neighbour that times out mid-vote — a default of "proceed" turns a network blip into a killed service.
- **`blacklist.properties` and `whitelist.properties` are the policy.** Adding a process to the blacklist is a behavioural change that needs a changelog entry; whitelist entries must win over blacklist entries, not the reverse.
- **Subnet scanning is noisy and slow.** The `/24` sweep on port 1099 needs a bounded timeout per host and a cap on concurrency; an unbounded scan hangs startup.
- **The singleton check must stay.** Each agent uses an RMI lookup to refuse to start when another `MASAgent` already runs on the host; removing it lets two agents vote twice.
- **Three threads run concurrently** — any shared collection they touch must be thread-safe or confined, and a new thread needs a stated shutdown path.
- Console output goes through the `Console`/`Colorize` helpers; Java 8 is the target.

### Commands a reviewer should be able to quote

```bash
mvn clean package                  # target/MAIS-<version>-jar-with-dependencies.jar
mvn test
mvn jacoco:report                  # target/site/jacoco/index.html
java -jar target/MAIS-<version>-jar-with-dependencies.jar
```

## Java conventions

See [Java Conventions](https://github.com/rios0rios0/guide/wiki/Java-Conventions), [Java Type System](https://github.com/rios0rios0/guide/wiki/Java-Type-System),
[Java Logging](https://github.com/rios0rios0/guide/wiki/Java-Logging), and
[Formatting and Linting](https://github.com/rios0rios0/guide/wiki/Java-Formatting-and-Linting).

- `PascalCase` for classes, `camelCase` for methods and fields; the `<Operation><Entity>`
  pattern for commands, controllers, services, repositories, and mappers.
- Entities stay framework-agnostic; persistence and transport annotations belong on the
  models and DTOs of the infrastructure layer.
- Logging goes through SLF4J with `{}` placeholders — never string concatenation, never
  `System.out.println` or `printStackTrace()`.
- Prefer records for immutable data and `Optional` over returning `null`; never use raw
  generic types or `Object` as a catch-all parameter.
- Catch the narrowest exception that can be thrown; an empty `catch` block, or one that only
  prints, is a finding.
- Formatting is Google Java Format via Spotless; Checkstyle and PMD findings are fixed, not
  suppressed without justification.

### Dispatch tables over `switch`

See [Mapper Design Pattern](https://github.com/rios0rios0/guide/wiki/Mapper-Design-Pattern). Two or three stable cases may stay a
`switch`. Four or more, or a set that grows with features, becomes a map from key to handler
so that adding a case is a new entry rather than an edit to the dispatcher. Flag new
`switch`/`if-else` chains that dispatch on a string or enum key.

## Tests

See [Tests](https://github.com/rios0rios0/guide/wiki/Tests).

- Only `MainTest` exists today; JaCoCo runs automatically under `mvn test`.
- A change to the consensus or enforcement logic needs a test with a synthetic neighbour set — those paths must not be verified by running the agent on a real network.

### Rules that hold for every test in this repository

- **BDD blocks are mandatory.** Every test body carries `// given` / `// when` / `// then`
  (`# given` / `# when` / `# then` in Python) delimiting preconditions, the action, and the
  assertions. A test without them is a finding.
- **Descriptions follow the layer.** Commands: `"should call <listener> when …"`.
  Controllers: `"should respond <HTTP_STATUS> when …"`. Services and repositories:
  `"should … when …"`, with at least one success and one failure case per public method.
- **Mock libraries are banned** — the category, not just the names: `testify/mock`,
  `golang/mock`, `mockery`, `go-sqlmock`, `httpmock`, `gock`, Mockito, EasyMock, PowerMock,
  `unittest.mock`, `pytest-mock`, `responses`, `requests-mock`, `jest.mock()` module mocking,
  `sinon`, `nock`, `testdouble`. Doubles are hand-rolled: stubs return canned answers,
  in-memory implementations hold state, and a spy that records calls is used only when
  nothing observable exists. Reaching for a mock library almost always means a port is
  missing — extract the interface the consumer needs instead.
- **Driver-level and transport-level mocks are the worst case.** SQL and HTTP behaviour is
  proven against the real thing: a real database with the real migrations for stores, a real
  local test server for outbound clients. Those are not mocks; they are real implementations
  under test control.
- **Builders construct test data.** Complex entities and DTOs come from builders, not from
  long literal structs repeated across files.
- A test deleted, skipped, or weakened to make a change pass is a Critical finding.

## Documentation and change control

See [Documentation & Change Control](https://github.com/rios0rios0/guide/wiki/Documentation-&-Change-Control) and
[CHANGELOG Formatting](https://github.com/rios0rios0/guide/wiki/CHANGELOG-Formatting).

This repository uses **chlog fragments**. `CHANGELOG.md` is generated and is never edited by
hand.

- Every change ships a fragment created with `chlog new --kind <Kind> --body "…"`, staged in
  the **same commit** as the code. Kinds: `Added`, `Changed`, `Deprecated`, `Removed`,
  `Fixed`, `Security`.
- A backward-incompatible change to the public interface additionally carries `--breaking`.
  The kind alone never triggers a major bump.
- A hand-edited `CHANGELOG.md`, or a code change with no fragment under
  `.changes/unreleased/`, is a **Critical** finding — `chlog check` fails the build for it.
- Fragment bodies start with a lowercase verb in simple past tense, capitalise proper nouns
  (GitHub, Go, Docker), and wrap code identifiers and versions in backticks.
- `README.md` is updated whenever usage, setup, configuration, or architecture changes;
  `.github/copilot-instructions.md` and `CLAUDE.md` whenever the workflow, commands, or
  structure changes. Documentation and code ship in one commit.

## Git Flow and pull-request hygiene

See [Git Flow](https://github.com/rios0rios0/guide/wiki/Git-Flow) and [Merge Guide](https://github.com/rios0rios0/guide/wiki/Merge-Guide).

- Branch names are `feat/`, `fix/`, `refactor/`, `chore/`, `test/`, or `docs/` followed by a
  ticket ID or a short slug — `feat/TICKET-000`, `fix/input-mask`.
- Commit subjects are `type(SCOPE): message`: simple past tense (`added`, `fixed`, `changed`,
  `removed`), lowercase first word, no trailing period, code identifiers in backticks.
- Branches are synchronised with `git rebase`, never `git merge`. A merge commit from the
  default branch inside a feature branch is a finding.
- Breaking changes are flagged in **three** places: the commit footer
  (`**BREAKING CHANGE:** …`), the changelog, and the pull-request description. One or two of
  the three is not enough.
- Versions follow [SemVer](https://semver.org/): MAJOR for incompatible changes, MINOR for
  features, PATCH for fixes.

## Security

See [Security](https://github.com/rios0rios0/guide/wiki/Security).

- **No hard-coded secrets.** API keys, tokens, passwords, and private keys belong in
  environment variables or a secret manager — never in source, tests, fixtures, or the
  changelog. A secret that reaches a commit must be rotated, not merely deleted.
- **Never write a PEM header sentinel or a realistic key shape into a fixture**
  (`ghp_…`, `sk-…`, `AKIA…`, `xoxb-…`, JWT-shaped strings, or the dashed `BEGIN …` banners).
  Gitleaks matches the shape, not the value, so a placeholder that merely *looks* like a
  credential fails the pipeline. Use inert placeholders such as `fixture-token-placeholder`.
- **Suppressions must be justified.** Entries in `.gitleaksignore`, `.trivyignore`,
  `.semgrepignore`, or `.codeql-false-positives` need a fingerprint, a dated comment, and a
  reason. A suppression added to silence a real finding is a Critical.
- Validate and sanitise every external input; use parameterised queries; apply least
  privilege; keep secrets out of logs.
- Dependency manifest changes are reviewed for new transitive vulnerabilities. When a fix
  exists, bump the version rather than suppressing the finding.

## What not to flag

A review that raises noise gets ignored. Do not report these:

- The research-project shape and the Portuguese console output.
- The absence of `make` targets; this project builds with Maven directly.
- Anything the guide does not require and this file does not list, unless it is a genuine correctness or security defect — say so plainly and label it a Suggestion.

## Review output format

```
## Code review: <branch or PR>

### Critical (must fix before merge)
- `path/to/file.ext:LINE` — <what is wrong> — violates <rule> (<guide page or repo file>)

### Warning (should fix)
- `path/to/file.ext:LINE` — <what is wrong> — violates <rule>

### Suggestion (optional)
- `path/to/file.ext:LINE` — <improvement>

### Change-control checklist
- [ ] Changelog entry present for every behavioural change
- [ ] `README.md` updated if usage, setup, or architecture changed
- [ ] `.github/copilot-instructions.md` and `CLAUDE.md` updated if the workflow, commands, or structure changed
- [ ] Commit messages follow `type(SCOPE): message` in simple past tense
- [ ] Breaking changes flagged in the commit footer, the changelog, and the PR description

### Verdict: APPROVE / REQUEST CHANGES
<one paragraph: the blocking findings, or why the change is ready>
```

## Severity

| Severity       | Use for                                                                                                                            |
|----------------|------------------------------------------------------------------------------------------------------------------------------------|
| **Critical**   | Broken dependency direction, a leaked secret, an injection or authentication flaw, a missing changelog entry, a banned mock library, a load-bearing invariant broken, a test deleted rather than fixed. |
| **Warning**    | Naming that departs from the guide, a missing test for a new branch of logic, an unexplained magic value, a stale README or instructions file, a `switch` that should be a map. |
| **Suggestion** | Readability, consistency with neighbouring modules, and performance ideas that no rule mandates.                                     |

Rank findings most severe first, and state plainly when nothing blocks the merge — an empty
Critical section is a valid, useful review.
