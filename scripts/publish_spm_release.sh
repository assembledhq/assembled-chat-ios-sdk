#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Publish a new AssembledChat SDK version via Swift Package Manager.

SPM "publishing" is pushing a SemVer git tag (e.g. 1.1.1).

Usage:
  bash scripts/publish_spm_release.sh [version] [options]

Examples:
  bash scripts/publish_spm_release.sh 1.1.1
  bash scripts/publish_spm_release.sh --bump patch
  bash scripts/publish_spm_release.sh 1.1.1 --dry-run

Options:
  --dry-run            Print what would happen, but make no changes.
  --skip-build         Skip the Xcode build preflight.
  --no-gh-release      Do not create a GitHub Release (even if gh is installed).
  --bump <kind>        If version is omitted, bump from latest tag: patch|minor|major (default: patch).

Notes:
  - Releases must be tagged on 'master' or 'main'
  - Tags are unprefixed (e.g. 1.1.0, not v1.1.0)
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

info() {
  echo "==> $*"
}

run() {
  if [[ "${DRY_RUN}" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

is_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+([\-][0-9A-Za-z\.-]+)?([+][0-9A-Za-z\.-]+)?$ ]]
}

latest_stable_tag() {
  git tag --list \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -n 1
}

next_version() {
  local bump_kind="$1"
  local latest
  latest="$(latest_stable_tag)"

  if [[ -z "${latest}" ]]; then
    echo "1.0.0"
    return 0
  fi

  local major minor patch
  IFS='.' read -r major minor patch <<<"${latest}"

  case "${bump_kind}" in
    patch)
      patch="$((patch + 1))"
      ;;
    minor)
      minor="$((minor + 1))"
      patch="0"
      ;;
    major)
      major="$((major + 1))"
      minor="0"
      patch="0"
      ;;
    *)
      die "--bump must be one of: patch|minor|major (got: ${bump_kind})"
      ;;
  esac

  echo "${major}.${minor}.${patch}"
}

DRY_RUN="0"
SKIP_BUILD="0"
NO_GH_RELEASE="0"
BUMP_KIND="patch"

VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN="1" ;;
    --skip-build) SKIP_BUILD="1" ;;
    --no-gh-release) NO_GH_RELEASE="1" ;;
    --bump)
      shift
      [[ $# -gt 0 ]] || die "--bump requires an argument"
      BUMP_KIND="$1"
      ;;
    *)
      if [[ -z "${VERSION}" && "$1" != -* ]]; then
        VERSION="$1"
      else
        die "Unknown argument: $1"
      fi
      ;;
  esac
  shift
done

require_command git

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not inside a git repository"

git remote get-url origin >/dev/null 2>&1 || die "Missing 'origin' remote"

info "Fetching latest tags from origin…"
run git fetch origin --tags

if [[ -z "${VERSION}" ]]; then
  VERSION="$(next_version "${BUMP_KIND}")"
  info "No version provided; using ${VERSION} (bump: ${BUMP_KIND})"
fi

if [[ "${VERSION}" == v* ]]; then
  die "Tags in this repo are unprefixed (e.g. 1.1.0). Please pass version without leading 'v'. Got: ${VERSION}"
fi

is_semver "${VERSION}" || die "Version must be SemVer (e.g. 1.2.3). Got: ${VERSION}"

CURRENT_BRANCH="$(git branch --show-current || true)"
if [[ -z "${CURRENT_BRANCH}" ]]; then
  die "You are in a detached HEAD. Check out 'master' (or your release branch) before publishing."
fi

if [[ "${CURRENT_BRANCH}" != "master" && "${CURRENT_BRANCH}" != "main" ]]; then
  die "Refusing to release from branch '${CURRENT_BRANCH}'. Switch to 'master' or 'main'."
fi

UPSTREAM_REF="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
[[ -n "${UPSTREAM_REF}" ]] || die "Branch '${CURRENT_BRANCH}' has no upstream. Set it (e.g. git push -u origin ${CURRENT_BRANCH}) before releasing."

LOCAL_SHA="$(git rev-parse HEAD)"
UPSTREAM_SHA="$(git rev-parse '@{u}')"
if [[ "${LOCAL_SHA}" != "${UPSTREAM_SHA}" ]]; then
  die "Local HEAD (${LOCAL_SHA:0:7}) != upstream (${UPSTREAM_SHA:0:7}). Push/fast-forward before releasing."
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git status --porcelain >&2
  die "Working tree is not clean. Commit/stash changes before releasing."
fi

if git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null; then
  die "Tag '${VERSION}' already exists."
fi

if [[ "${SKIP_BUILD}" == "0" ]]; then
  require_command xcodebuild
  info "Building via xcodebuild…"
  run xcodebuild -scheme AssembledChat -destination "generic/platform=iOS Simulator" build
else
  info "Skipping build preflight (--skip-build)."
fi

info "Creating annotated git tag '${VERSION}'…"
run git tag -a "${VERSION}" -m "Release ${VERSION}"

info "Pushing tag '${VERSION}' to origin…"
run git push origin "${VERSION}"

if [[ "${NO_GH_RELEASE}" == "1" ]]; then
  info "Skipping GitHub Release creation (--no-gh-release)."
  exit 0
fi

if command -v gh >/dev/null 2>&1; then
  info "Creating GitHub Release '${VERSION}' (auto-generated notes)…"
  run gh release create "${VERSION}" --title "${VERSION}" --generate-notes
else
  info "gh not found; skipping GitHub Release creation."
fi

info "Done. SPM clients can now resolve version '${VERSION}'."
