## Release scripts

### Publish a new SPM version

SPM “publishing” is pushing a SemVer git tag.

This repo uses **unprefixed tags** (e.g. `1.1.0`, not `v1.1.0`).

From the repo root:

```bash
bash scripts/publish_spm_release.sh [version]
```

Examples:

```bash
# Explicit version
bash scripts/publish_spm_release.sh 1.1.1

# Auto-bump from latest tag (default: patch)
bash scripts/publish_spm_release.sh

# Auto-bump minor/major
bash scripts/publish_spm_release.sh --bump minor
bash scripts/publish_spm_release.sh --bump major
```

Common options:

```bash
# Print commands without making changes
bash scripts/publish_spm_release.sh 1.1.1 --dry-run

# Skip build preflight
bash scripts/publish_spm_release.sh 1.1.1 --skip-build

# Skip creating a GitHub release (tag push still happens)
bash scripts/publish_spm_release.sh 1.1.1 --no-gh-release
```

### What it checks / enforces

- You’re on `master` or `main` (refuses other branches)
- Your local branch is **exactly** in sync with its upstream (`origin/...`)
- Your working tree is clean
- The tag doesn’t already exist
- Runs an `xcodebuild` preflight unless `--skip-build` is provided

