# AGENTS Guide for `dc3-parent`

## What this repository is

- This repo is a **Maven parent/BOM project** (`packaging=pom`) for IoT DC3, not an application runtime.
- The core source of truth is `pom.xml`; there are no Maven `<modules>` in this repository.
- Main purpose: centralize dependency versions, plugin management, and release/deploy rules for downstream DC3 components.

## Big-picture structure

- `pom.xml` defines version catalogs in `<properties>` and pins framework baselines (Spring Boot/Cloud, gRPC, MyBatis, etc.).
- `pom.xml` also centralizes plugin behavior in `<pluginManagement>` (compiler, enforcer, protobuf, native, source/javadoc/gpg, central publishing).
- Release automation is split between:
    - `dc3/bin/tag.sh` (version bump + git tag + push)
    - `.github/workflows/maven-publish.yml` (deploy + GitHub Release on `dc3.release.*` tags)

## High-value workflows

- Fast local validation:
    - `mvn -B -ntp clean verify`
- Dependency tree inspection profile:
    - `mvn -B -ntp verify -P dep-tree`
- Plugin/property update report profile:
    - `mvn -B -ntp verify -P version`
- Deploy profile (mirrors CI intent):
    - `mvn --settings .github/maven-settings.xml -B -ntp clean deploy -P deploy -DskipTests`
- Automated tagging flow:
    - `bash dc3/bin/tag.sh`

## Project-specific conventions to preserve

- Java baseline comes from `pom.xml` property `java.version` (currently `21`) via `maven-compiler-plugin` `<release>`.
- Enforcer requires Maven `>= 3.8.0`; do not lower this without updating `maven-enforcer-plugin` config.
- Annotation processing is intentional: Lombok + MapStruct + `lombok-mapstruct-binding` are configured in compiler plugin paths.
- Resource filtering is enabled globally; binary-like extensions are explicitly excluded (`ico`, `db`, `key`, `crt`, `p12`, `proto`, `json`, `xls`, `xlsx`).
- Release commits/titles follow existing prefixes from docs/scripts (examples: `fix: ...`, `docs: ...`, `release: <version>`).

## CI/CD and external integration points

- GitHub Action `.github/workflows/maven-publish.yml` runs on push tags matching `dc3.release.*`.
- Publish pipeline expects server id `pnoker` from `.github/maven-settings.xml` and secrets `SERVER_USERNAME` / `SERVER_PASSWORD`.
- GPG signing is part of deploy profile (`maven-gpg-plugin`) and CI imports private key before deploy.
- Sonatype Central publishing is configured via `central-publishing-maven-plugin` (`publishingServerId=pnoker`, `autoPublish=true`).

## Agent guardrails for edits

- Treat `pom.xml` as a compatibility contract for downstream projects; prefer minimal, targeted changes.
- Keep versions in `<properties>` and reference them; avoid hardcoded versions in dependency/plugin entries.
- When changing release logic, update both `dc3/bin/tag.sh` and `.github/workflows/maven-publish.yml` if behavior must stay aligned.
- If you touch contributor-facing process, cross-check wording with `CONTRIBUTING.md` prefixes/templates.

