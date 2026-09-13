---
name: github-cli
description: Use the GitHub CLI `gh` to work with repositories, issues, pull requests, GitHub Actions, and releases. Activate when the user asks to create/list/update/close issues, open or review pull requests, run or inspect CI (Actions), check workflow runs, create releases, or manage GitHub repos. Also activate when the user says "GitHub", "PR", "pull request", "issue", "workflow", "Actions", or "release".
---

# GitHub CLI

A CLI for the GitHub API via `gh`. Use `gh <command> --help` for full flags — this
skill only covers what `--help` cannot tell you.

## Setup

- If `gh` is not installed: `brew install gh`, `apt install gh`, or the official
  tarball. Then configure: `gh auth login`.
- Check auth: `gh auth status`. Verify the profile owns a host:
  `gh api user --jq .login`.
- Credentials may be read from `GH_TOKEN`/`GITHUB_TOKEN` (a fine-grained PAT is
  enough for most automation in an agent context).
- `gh repo set-default` pins the repo so most commands don't need `-R owner/repo`.
  When running from a checkout, `gh` auto-detects the repo from the remote.
- Escape non-default hosts with `-R hostname/owner/repo` (e.g. GitHub Enterprise).

## Critical Rules

- **Always use `--json` + `--jq`** to consume output programmatically. JSON is
  stable; the human table output is not. Example:
  `gh pr list --json number,title,author,mergeable --jq '.[] | "\(.number) \(.title)"'`.
- **Use `gh api`** for anything `gh` doesn't wrap directly. It speaks the REST
  API: `gh api repos/{owner}/{repo}/issues`,   `gh api -X POST ...`. Add
  `-H "Accept: application/vnd.github+json"` only when a preview/field requires it.
- Pagination: `gh api --paginate` follows the `Link` headers automatically and
  fetches every page. Do not hand-roll pagination loops.
- **Never invent flags.** If a list/create/merge command fails or you are unsure,
  run `gh <command> --help` and read the actual options. Do not loop on guesses.
- Prefer `--jq` over `--template` for anything non-trivial; if the JSON field
  doesn't exist, check the entity's schema via `gh api` on a single item.

## Issues

- **List**: `gh issue list --repo owner/repo [--assignee @me] [--label bug] [--state open]`
- **Get details + comments + body**: `gh issue view <num> --comments --json ...`
- **Create**: `gh issue create --title "..." --body "..." [--label ...] [--assignee @me] [--milestone ...]`
- **Update**: `gh issue edit <num> --add-label ... --remove-label ... --add-assignee @me`
- **States**: `gh issue close <num> [--reason completed]`, `gh issue reopen <num>`
- **Comment**: `gh issue comment <num> --body "..."` (also supports `--edit-last`, `--web` edits)

### Resolving labels / assignees / milestones without IDs

`gh` accepts names directly (`--label`, `--assignee`, `--milestone <!-- user -->`).
If the environment migrated away from the old workflows, e.g. PR-based
repositories reference a project, inspect `gh issue view <num> --json labels,assignees,milestone`.

## Pull Requests

- **List / filter**: `gh pr list --state open --draft`,
  `gh pr list --search "is:pr review-requested:@me"` (search query reference: their
  `gh help search-pr` allows `--search` filters such as `is:pr`/`is:open`/`draft:true`).
- **Get full context**: `gh pr view <num> --comments --reviews --json ...` (omit
  diff; fetch it separately with `--diff` or `gh pr diff <num>`).
- **Create**: `gh pr create --base main --head branch --title --body` and NEVER
  reference merge base — git + gh handle it. Optionally `--fill` to reuse
  commit-message/body, or `--draft`, `--web`.
- **Review**: `gh pr review <num> --approve` / `--request-changes --body "..."` /
  `--comment`. Distinguish a *review comment* (on the diff) from a *general
  pull request comment*.
- **Request review**: `gh pr edit <num> --add-reviewer @me` (`--add-reviewer` takes
  usernames; a `@me` is not valid there — use `--assignee @me` for assignment).
- **Merge**: `gh pr merge <num> [--squash|--rebase|--merge] [--delete-branch] [--admin]`.
  When branch protection blocks, `--admin` forces it if you have permission; else
  report the failing checks.
- **Checks**: `gh pr checks <num> --watch` reports CI status; `--fail-fast`.
- **Code review workflow**: view diff first (`gh pr diff`), leave inline comments
  with `gh pr review <num> --comment --body "..."` (or `gh api` for pull request
  review threads), then approve or request changes. Cite the exact file:line you
  reviewed.

## GitHub Actions (CI / CD)

- **List runs**: `gh run list --branch main --limit 10 --json ...`
- **Inspect / watch**: `gh run view <run-id> [--log] [--watch]`
- **Re-run**: `gh run rerun <run-id> [--failed]`
- **Trigger manually**: `gh workflow run <name|file.yml> [--ref branch] [-f key=value]`
- **Inspect a workflow file** in the repo rather than guessing; jobs → steps → uses.
  Secrets/inputs are not in logs; if a step fails from an unset var, check the
  workflow file and the Actions run env, not random assumptions.
- Download artifacts: `gh run download <run-id> -n <artifact> -D <dir>`.
- After a push, wait for the run with `gh run watch <run-id>`.

## Releases

- **List**: `gh release list`
- **Create**: `gh release create v1.0.0 --title "..." --notes "..." [assets...]`
- **Draft / edit**: `gh release edit v1.0.0`, `gh release delete v1.0.0`
- **Download**: `gh release download v1.0.0 --pattern '*.tar.gz'`

## Repos & More

- `gh repo view owner/repo`, `gh repo clone`, `gh repo create`
- `gh repo fork`, `gh repo set-default`
- Search: `gh search issues -- "..."`, `gh search code -- "..."` (needs auth)
- `gh alias` for recurring custom commands; `gh extension` to install trusted
  extensions (e.g. `gh extension install github/gh-copilot` for `gh copilot`).
- **Gists**: `gh gist create --public file`, `gh gist view <id>`.

## After Creating Resources

After creating an issue/PR/release, surface the result URL in your answer:
`gh issue view <num> --json url --jq .url` (or `gh browse <num>`). Clickable links
are far more useful than bare IDs.
