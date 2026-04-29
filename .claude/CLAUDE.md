# CLAUDE.md - IoT DC3 Parent Project

## Project Overview

IoT DC3 Parent (`dc3-parent`) is a Maven parent/BOM project (`packaging=pom`) for the IoT DC3 distributed IoT platform. It centralizes dependency versions, plugin management, and release/deploy rules for downstream DC3 components. There are no Maven `<modules>` in this repository — the source of truth is `pom.xml`.

## Tech Stack

- **Language:** Java 25
- **Build:** Maven (>= 3.8.0)
- **Framework baselines:** Spring Boot 4.0.5, Spring Cloud 2025.1.1
- **Key dependencies:** gRPC 1.80.0, Protobuf 4.34.1, MyBatis Plus 3.5.16, Jackson 2.21.2, Netty 4.2.10
- **CI/CD:** GitHub Actions (`.github/workflows/maven-publish.yml`)
- **Publishing:** Sonatype Central (`central-publishing-maven-plugin`)

## File Structure

```
.
├── pom.xml                  # Central BOM: all versions, plugin management
├── dc3/bin/tag.sh           # Version bump + git tag script
├── .github/
│   ├── maven-settings.xml   # Maven server config for CI
│   └── workflows/
│       └── maven-publish.yml # Deploy + GitHub Release workflow
├── CONTRIBUTING.md          # Contributor guide
└── README.md                # Project README
```

## Common Commands

```bash
# Local validation
mvn -B -ntp clean verify

# Dependency tree inspection
mvn -B -ntp verify -P dep-tree

# Plugin/property update report
mvn -B -ntp verify -P version

# Deploy (mirrors CI)
mvn --settings .github/maven-settings.xml -B -ntp clean deploy -P deploy -DskipTests

# Version bump + git tag
bash dc3/bin/tag.sh
```

## CI/CD

- GitHub Action `.github/workflows/maven-publish.yml` runs on push tags matching `dc3.release.*`.
- Publish pipeline expects server id `pnoker` from `.github/maven-settings.xml` and secrets `SERVER_USERNAME` / `SERVER_PASSWORD`.
- GPG signing is part of deploy profile (`maven-gpg-plugin`) and CI imports private key before deploy.
- Sonatype Central publishing via `central-publishing-maven-plugin` (`publishingServerId=pnoker`, `autoPublish=true`).

## Conventions

- All dependency/plugin versions must be defined in `<properties>` and referenced — never hardcoded.
- Release commits follow prefixes: `release: <version>`, `fix: ...`, `docs: ...`, `chore: ...`.
- GPG signing is required for deploy profile.
- The `java.version` property controls the compiler release target — currently `25`.

## Guardrails

- Treat `pom.xml` as a compatibility contract for downstream projects — prefer minimal, targeted changes.
- When changing release logic, update both `dc3/bin/tag.sh` and `.github/workflows/maven-publish.yml` to keep behavior aligned.
- Do not lower Maven enforcer minimum (currently `>= 3.8.0`) without updating plugin config.
- Annotation processing (Lombok + MapStruct + `lombok-mapstruct-binding`) is intentional — do not remove compiler plugin paths.
- Resource filtering is enabled globally; binary-like extensions are excluded (`ico`, `db`, `key`, `crt`, `p12`, `proto`, `json`, `xls`, `xlsx`).
- If you touch contributor-facing process, cross-check wording with `CONTRIBUTING.md` prefixes/templates.

## Code Style

- XML indentation: 4 spaces
- Keep `<properties>` sorted by category (Build basics → Framework → RPC → Data access → Serialization → Platform utilities)
- Maintain alphabetical ordering within `<dependencyManagement>` and `<pluginManagement>` where possible