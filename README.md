# IoT DC3 Parent Maven BOM

`dc3-parent` is the Maven parent/BOM project for IoT DC3.
It centralizes dependency versions, plugin management, and release/deploy conventions for downstream components, while keeping IoT DC3 AI-ready for intelligent device connectivity,
automation, and data-driven operations.

## What This Repository Provides

- Unified version catalog in `pom.xml` (`<properties>`, `<dependencyManagement>`)
- Shared build plugin behavior in `pom.xml` (`<pluginManagement>`)
- Release automation via `dc3/bin/tag.sh` + GitHub Actions publish workflow
- Compatibility baseline for downstream projects (Java, Maven, plugin, and dependency alignment)

## Key Files

- `pom.xml`: source of truth for dependency and plugin versions
- `dc3/bin/tag.sh`: bumps project version, creates/pushes release tag
- `.github/workflows/maven-publish.yml`: deploys and creates GitHub Release on `dc3.release.*` tags
- `.github/maven-settings.xml`: CI publishing server id and credential mapping

## Common Commands

```bash
mvn -B -ntp clean verify
mvn -B -ntp verify -P dep-tree
mvn -B -ntp verify -P version
mvn --settings .github/maven-settings.xml -B -ntp clean deploy -P deploy -DskipTests
bash dc3/bin/tag.sh
```

## Release Flow

1. Run `bash dc3/bin/tag.sh` on `develop`, `release`, or `main`.
2. Script updates `pom.xml` version, commits with `release: <version>`, and pushes tag.
3. Tag matching `dc3.release.*` triggers `.github/workflows/maven-publish.yml`.
4. CI imports GPG key, deploys with `-P deploy`, then creates a GitHub Release.

## Contribution Notes

- Use contribution templates and prefixes in `CONTRIBUTING.md` (for example: `docs:`, `fix:`).
- Keep dependency/plugin versions in `pom.xml` properties; avoid scattered hardcoded versions.
- Treat this repo as a shared contract for downstream modules; prefer minimal and targeted changes.
