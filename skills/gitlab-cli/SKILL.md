---
name: gitlab-cli
description: Use the GitLab CLI `glab` to work with repositories, issues, merge requests, pipelines/CI, snippets, and the GitLab API. Activate when the user asks to create/list/update/close issues, open or review merge requests, run or inspect CI pipelines and jobs, create snippets, or manage GitLab repos/groups. Also activate when the user says "GitLab", "MR", "merge request", "issue", "pipeline", "CI", or "glab".
---

# GitLab CLI

A CLI for the GitLab API via `glab`. Use `glab <command> --help` for full flags —
this skill only covers what `--help` cannot tell you.

## Setup

- Install: `brew install glab` or `apt install gitlab-cli`.
- Authenticate: `glab auth login` (OAuth or a personal access token). The active
  host can be `gitlab.com` or a self-hosted instance (GitLab EE/CE).
- Check: `glab auth status`. List hosts: `glab auth status --show-token`.
- Verify connectivity: `glab api user --jq .username`.
- The active repo is auto-detected from the closest `gitlab.com/...` remote
  (`glab config get-gitlab-...`); to target another project:
  `glab --repo group/project` or `-R`.

## Critical Rules

- **Always use `--output json` and `--jq`** for programmatic consumption; the
  table/`--output yaml` forms are for humans. Example:
  `glab issue list --json --jq '.[] | "\(.iid) \(.title)"'` (iid = instance-wide
  issue ID; always reference MR/issues by **IID** when talking to the server).
- **Use `glab api`** for anything missing: `glab api projects/:id/...`,
  `glab api --method POST projects/:id/variables { ... }`. Supports `--paginate`.
- **Paginate**: list endpoints default to `--per-page 20`. Use `--per-page 100`
  for larger sets, or `--paginate` for all.
- **Never invent flags/subcommands.** If a command fails or you are unsure, run
  `glab <command> --help` and follow the help output. Do not loop on guesses.
- When working with a group, remember many commands accept `-R group/project` and
  group-level resources use `groups/:id/...` in `glab api`.
- GitLab MRs force author-approval, squash, and other configured rules at the
  project level. If a merge is blocked, inspect `glab mr view <iid> --json` for
  `detailedMergeStatus` / `merge_error`, not random retries.

## Issues

- **List**: `glab issue list [--milestone] [--label ...] [--search ...]`
- **Get**: `glab issue view <iid>` (includes comments).
- **Create**: `glab issue create --title "..." --description "..." [--label ...] [--assignee @me] [--milestone ...]`
- **Update**: `glab issue update <iid> --label ... --remove-label ... --assignee @me`
- **States**: `glab issue close <iid>`, `glab issue reopen <iid>`
- **Comment**: `glab issue note <iid> --message "..."`.

### References without IDs

`glab` resolves labels, milestones, assignees, and `--repo` by name. For project
refs past the default: `glab issue create --repo group/project ...`; no lookup
needed. When a search feels obscured, `glab issue list --all --json` returns the
matching items to filter.

## Merge Requests

- **List**: `glab mr list [--state open] [--label ...]`
- **Get**: `glab mr view <iid>` and `glab mr diff <iid>` for the full diff (view
  the diff before approving).
- **Create**: `glab mr create --source-branch <branch> --target-branch <main> --title --description [--draft] [--remove-source-branch]`
- **Review / approve**: `glab mr approve <iid>`, `glab mr revoke <iid>`,
  `glab mr note <iid> --message "..."` (comments).
- **Update labels/assignees**: `glab mr update <iid> --label ... --unlabel ... --assignee ...`
- **Merge**: `glab mr merge <iid> [--squash] [--when-pipeline-succeeds] [--remove-source-branch]`
- **Checks / pipelines**: `glab ci status`, `glab ci view --branch <branch>`.
- **Code review flow**: pull the diff, leave inline notes (`glab mr note <iid>
  --message`), then approve or request changes. Comments can be left on a specific
  line with `glab api` (`discussions` with position) when needed; otherwise a
  top-level note suffices.

## CI / CD (Pipelines)

- **List pipelines**: `glab ci list [--branch <branch>]`
- **View**: `glab ci view <pipeline-id>` and `glab ci view --branch <branch>`; logs
  per job: `glab ci trace <pipeline-id> <job-id>`.
- **Re-run**: `glab ci retry <pipeline-id> <job-id>`
- **Trigger**: `glab pipeline run [--ref <branch>] [--variables VAR=VAL]`
- Read `.gitlab-ci.yml` in the repo to understand jobs/stages before debugging a
  failed run: variables/secrets are masked in logs. Check `glab ci view --json` for
  statuses and job names.
- Artifacts: use `glab api` (jobs/:id/artifacts) or the web UI; there is no
  dedicated download subcommand in older glab.

## Snippets

- `glab snippet create --title "..." --file <path>` (or `--filename` with stdin).
- `glab snippet view <id>`, `glab snippet list`.

## Releases, Refs & More

- `glab release create <tag> --name --description [--description-file notes.md]`
- `glab release view <tag>`, `glab release list`
- `glab auth login` refresh, `glab alias`.

## After Creating Resources

After creating an issue/MR/release, surface the URL in your answer:
`glab issue view <iid> --json web_url --jq .web_url` (MR: `glab mr view <iid> --json
web_url --jq .web_url`). Clickable links beat bare IDs.
