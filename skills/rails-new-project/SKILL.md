---
name: rails-new-project
description: Bootstrap a brand-new Ruby on Rails application. Activate when the user asks to create/start/scaffold a new Rails app, initialize a fresh Rails project, generate `rails new`, set up a new repo + git remote, provision a devcontainer, or establish a Vue-like dev loop for a Rails app that does not exist yet. Also activate on "new rails project", "rails new", "create a rails app", "new app", or "scaffold rails".
---

# Rails: New Project

Bootstraps a brand-new Rails application, end to end: toolchain via `mise`,
scaffold via `rails new`, database, devcontainer, Redmine project + ticket
context, git remote, first smoke run, and initial commit.

Run `rails --help` / `rails new --help` before assuming flags — this skill only
covers what the Rails generator cannot tell you.

## Phase 0 — Choose a directory, then verify toolchain

The working directory MUST exist and be empty before `rails new`.

1. `mise current ruby` and `mise current node`. Note what is or is not pinned.
2. If Ruby is **not** pinned in the current config → use the **latest stable
   Ruby** that mise can install: `mise ls-remote ruby | tail -1` (or `mise
   ls-remote ruby | sort -V | tail -1`) and note it as the target.
3. If Node is **not** pinned → `mise ls-remote node | sort -V | tail -1`.
4. Before scaffolding, read the intended Rails version target:

   - Look at the **latest Rails** the toolchain can produce:
     `gem info rails --remote` (shown version is the latest release).
   - Use the latest Rails unless the user explicitly asked for a specific
     version, or the pinned Ruby cannot host that Rails (a very new Rails may
     require a Ruby newer than what is pinned — bump Ruby first or pick the
     newest Rails the Ruby supports).

> Only the test-framework default is decided here: **default to Minitest** (the
> Rails default) unless the user explicitly asks for RSpec or some other
> framework. Do not hardcode otherwise — the project's Gemfile determines it
> later.

## Phase 1 — Redmine project context (ask before scaffolding)

The project needs a Redmine project to hang tickets on, and a git remote.

- `redmine projects list -o json` → list existing projects.
- **Ask the user**: use an existing Redmine project, or should you create a new
  one?
  - Existing: `redmine projects show <id> -o json` to confirm reachable.
  - New: `redmine projects create --name "..." --identifier <slug> --description "..."` 
    and capture the returned project id + URL. Configure the CLI to default to it
    for all later redmine/ticket work: `redmine config set-default-project <id>`.
- Similarly, **ask for the git remote**: `git remote add origin <url>` once you
  know the URL. If the user doesn't have one yet, either the redmine CLI can
  provision repo hosting (invite/collab) or you create the repo (see the
  github-cli / gitlab-cli / redmine projects create skill as relevant). Record
  the chosen Redmine project id — it becomes the default context for the whole
  project.

Never guess a project id or remote URL; always ask.

## Phase 2 — Scaffold with `rails new`

Use `rails new` with the following **non-negotiable items**:

- `--database=postgresql` — PostgreSQL is required (propshaft stack).
- `--devcontainer` — ALWAYS generate the devcontainer. The project should be
  runnable inside a devcontainer from day one.
- Full web app (do NOT use `--api` unless explicitly requested).
- Asset handling: `propshaft` (default in modern Rails). If the user did not ask
  for a specific CSS/JS build, use the Rails default (importmap / propshaft /
  no-build). If they did ask (esbuild / Tailwind / React / etc.), honor it.
- Test framework: **default** (Minitest) unless the user asked otherwise
  (then e.g. `--skip-test` + add rspec-rails).

Decide remaining defaults by asking only when they matter (rare). Prefer the
Rails defaults. Scaffold with the chosen Ruby available via `mise exec`:

```bash
mise exec -- rails new . --database=postgresql --devcontainer [--css=...] [--javascript=...]
```

> `--devcontainer` populates `.devcontainer/` — but do not rely on it being
> wired to the toolchain automatically. Confirm `mise` is what the devcontainer
> uses (propshaft stack). Align `.mise.toml` tool versions with the dockerfile
> if the devcontainer images a more pinned set — see the `devcontainers-cli` skill
> for `devcontainer.json` + `Dockerfile` validation.

## Phase 3 — Wire up version manager (mise)

After scaffolding, the toolchain may not yet know the pinned versions. Pin what
the project needs:

```bash
mise use ruby@<chosen> node@<chosen>
```

and add the `[tools]` block to `.mise.toml`:

```toml
[tools]
ruby = "3.4.x"
node = "22.x"
```

Consider adding mise tasks: `mise run` for `test`, `lint`, and `server` so later
agents invoke consistent commands `mise exec -- bin/rails` etc. See the `mise`
skill.

## Phase 4 — Database, migration, and first boot

- `mise exec -- bin/rails db:create`
- `mise exec -- bin/rails db:migrate` (and `db:seed` if a seed exists).
- Boot-check the app: `mise exec -- bin/rails server` (or the devised task) and
  verify the root route responds; or run a smoke test (`mise run test`).

## Phase 5 — Git, remote, first commit

If `.git` is not initialized:

1. `git init`
2. Add the remote from Phase 1: `git remote add origin <url>`.
3. Add **all** new project files: `git add -A`.
4. `.gitignore` for `.env` / credentials — confirm the Rails default is in place.
5. First commit on the default branch.
6. **Push** to the remote, set upstream, and confirm the branch
   (`git branch --show-current`). Surface the repo URL so the user can open it.

## After Finishing

- Summarize what was created, the chosen Ruby/Rails/Node versions, the Redmine
  project id + URL, the git remote URL, and the first-boot confirmation.
- Give the clickable Redmine project URL and repo URL. If you created a Redmine
  ticket for "project setup", surface `redmine issues view <id> --json
  web_url --jq .web_url`.
