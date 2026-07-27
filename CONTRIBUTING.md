# Contributing

## Scope

Changes should keep this repository small, reproducible, and focused on a
single-host Docling Serve deployment. Upstream Docling or Docling Serve defects
belong in the corresponding upstream repository.

## Development workflow

1. Create a branch from the default branch.
2. Copy `.env.example` to `.env`.
3. Make the smallest coherent change.
4. Run `make validate`.
5. When runtime behavior changes, run `make start`, `make smoke`, and a
   representative document conversion.
6. Update `README.md`, relevant files under `docs/`, and `CHANGELOG.md`.
7. Open a pull request describing operational and compatibility impact.

## Conventions

- Documentation and code comments are written in English.
- Shell scripts use `set -euo pipefail`.
- Python utilities use only the standard library unless a dependency is clearly
  justified.
- Upstream images must be pinned to an explicit version.
- Secrets and company documents must never be committed.
- Avoid adding a custom container image unless the official image can no longer
  satisfy a documented requirement.
