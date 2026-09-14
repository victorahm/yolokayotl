---
name: rails-feature
description: Implement a small, well-scoped feature or a bug fix in an existing Ruby on Rails project. Activate when the user asks to add a feature or fix a bug in the current app, start work on a ticket (Redmine issue, GitHub/GitLab issue or MR), work test-first on a Rails change, or open a PR/MR for a Rails change. Also activate on "implement this", "fix this bug", "add feature", "start on <ticket>", "PR", "MR", or "work on <redmine/github/gitlab issue>".
---

# Rails: Feature / Bug Fix

Implements a single, well-scoped feature or bug fix in an existing Rails app,
test-first. The project's own conventions (test framework, devcontainer) are
detected from the repo — never assumed.

## Phase 0 — Detect the project context

1. **Ticket**: resolve the linked ticket's details via `redmine issues view <id>`,
   `gh issue view <num>`, or `glab issue view <iid>` (whichever the repo uses).
   Pull acceptance criteria, description, and any linked files. If there is no
   ticket, ask the user where the requirement comes from before starting.
2. **Test framework**: read `Gemfile`. If `rspec-rails` is present → RSpec;
   otherwise → Minitest (Rails default). Never hardcode.
3. **Command environment**: if a devcontainer config exists (`.devcontainer/`),
   ALL project commands run inside the devcontainer; otherwise via `mise`.
   See "Which commands to run" below.
4. **Branch**: create `feat/<slug>` or `fix/<slug>` off the current branch/Main.

## Which Commands to Run

- If `devcontainer` is configured (`.devcontainer/devcontainer.json` or
  `.devcontainer/Dockerfile` present) → run every project command inside it:

  ```bash
  devcontainer up --workspace-folder .
  devcontainer exec --workspace-folder . -- bundle exec rspec <spec>
  devcontainer exec --workspace-folder . -- bin/rails test <test>
  devcontainer exec --workspace-folder . -- bin/rails db:migrate
  devcontainer exec --workspace-folder . -- bundle exec rubocop
  ```

  Only fall back to `mise exec -- ...` when NO devcontainer config exists.
  See the `devcontainers-cli` skill for bringing the container up when it is not
  already running.

- **Test framework first**: 
  - RSpec: `devcontainer exec --workspace-folder . -- bundle exec rspec spec/<file>`
  - Minitest: `devcontainer exec --workspace-folder . -- bin/rails test test/<file>`
  Use the focused test command while developing; run the full suite before
  finishing.

## The Implementation Loop (TDD)

1. **Write a failing test first** that captures the acceptance criteria of the
   ticket. Run it and confirm it FAILS for the right reason (not a syntax error).
2. Implement the minimal code to make it pass.
3. Run the **focused test** → then the **full suite**.
4. Run the linter (RuboCop default: `bundle exec rubocop`).
5. Iterate: red-green-refactor; keep the change small and scoped.

## Pre-Finish Checks

- Full test suite passes (`devcontainer exec --workspace-folder . -- bin/rails
  test` or `bundle exec rspec`).
- Rubocop passes (or explain surviving offenses).
- If a migration/seed change is needed, update `db/schema.rb` and note the
  migration required.

## Phase 5 — Open PR/MR, then update the ticket

1. Commit the work on the feature branch.
2. Open a **draft** or normal PR/MR — `gh pr create`, `glab mr create`, or
   `devcontainer`-based repo as appropriate. Push, then capture the 
   PR/MR URL.
3. **If the ticket is a Redmine issue**, update its status per the project
   flow — e.g. move it from "In Progress" to a review/QA state:
   - `redmine statuses list -o json` to find the valid status names.
   - `redmine issues update <id> --status <valid-status>`.
   Always resolve the target status from the actual list, never invent one.
4. Surface: PR/MR URL + Redmine issue URL (`redmine issues view <id> -o json
   ...web_url`). Closing semantics follow the repo's convention — do not
   auto-close the ticket unless that is the established flow (typically the
   PR/MR → close-links it).

## After Finishing

- Summarize: changed files, test results (focused + full), lint status, the
  PR/MR URL, and the new ticket status. Mention where to review.
