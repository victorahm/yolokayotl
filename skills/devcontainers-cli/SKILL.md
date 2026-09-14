---
name: devcontainers-cli
description: Use the Dev Containers CLI (`devcontainer`) to provision and run development containers — build, start, exec into, and manage `.devcontainer/` setups including the Rails + Postgres + mise stack this repo scaffolds. Activate when the user asks to build/start/stop/exec a devcontainer, install features or templates, validate `devcontainer.json` or `Dockerfile`, or run commands/tests inside the project container. Also activate on "devcontainer", "dev container", "devcontainers", "container", "features", "templates".
---

# Dev Containers CLI

`devcontainer` is Microsoft's standalone CLI for starting and working inside
dev containers (no VS Code required). It reads `.devcontainer/devcontainer.json`
(RAILS: the `rails new --devcontainer` scaffold) and provisions the container,
features, and bind mounts.

Run `devcontainer --help` and `devcontainer <command> --help` for current flags.
This skill only covers what `--help` cannot tell you.

## Setup

- Install: `brew install devcontainers-cli` or
  `npm install -g @devcontainers/cli` (verify: `devcontainer --version`).
- `devcontainer --help` to see the full command set before guessing.

## Core Commands

- **Build the image**: `devcontainer build --workspace-folder <dir>`
- **Start (create) the container**: `devcontainer up --workspace-folder <dir>`
  — builds if needed, creates the container, applies features. Requires the
  Dockerfile/devcontainer.json. If it's not running, `up` first.
- **Run a command inside the running container**:
  `devcontainer exec --workspace-folder <dir> -- <cmd...>`
- **Validate config**: `devcontainer build --workspace-folder <dir> --no-cache`
  or just inspect `devcontainer.json` for validity.
- **List features/templates** (separate helper CLI / registry):
  - `devcontainer features` is not a real top-level there — features live in a
    registry (`devcontainer-features.json`). Use `devcontainer templates` /
    `devcontainer features` **only if present** in your installed version's
    `--help`; otherwise consult the registry docs. DO NOT invent flags.

## Feature/Template Usage (when supported)

- Add a feature to `devcontainer.json` via `"features": { ... }` then `devcontainer
  up` to apply it.
- Installing an existing feature by name/version requires knowing the exact
  registry id + version. Prefer `devcontainer features`/`templates` subcommands
  shown by `--help` for listing; otherwise ask the user which feature rather than
  guessing registry coordinates.
- Validate: `devcontainer build` a clean workspace to confirm the feature image
  builds (Rails: confirm `bundle exec rails db:create` boots inside).

## Rails + Postgres + mise notes

- The `rails new --devcontainer` scaffold (see `rails-new-project` skill) targets
  the full stack. Verify the `Dockerfile` pulls a Ruby matching `mise`'s pinned
  version (`mise current ruby`), and that the container runs with `mise` available.
- To run the whole Rails toolchain inside the container, use `devcontainer exec
  --workspace-folder . -- bundle exec rails server`, and the test suite likewise.
- If the Rails task uses mise tasks: `devcontainer exec --workspace-folder . -- mise
  run test` (only if `mise` is installed in the image).

## When Something Doesn't Work

- "Container not running": run `devcontainer up --workspace-folder <dir>` first
  and confirm it reports ready.
- Feature/template not found: do NOT retry invented names — run the `--help`
  output for the exact subcommand or ask the user.
- Docker/CLI mismatch: `devcontainer --version` and confirm Docker Desktop /
  docker daemon is up (`docker ps`). The CLI shells out to Docker; if Docker is
  down, nothing works.
- Never guess `devcontainer.json` schema keys beyond what `devcontainer.json`
  reference documents; validate with a build rather than assumptions.
