# yolokayotl

Personal collection of agent skills for Ruby on Rails development. Each skill is a
directory containing a `SKILL.md` (with opencode-style frontmatter) that teaches a
CLI agent how to drive a specific tool for Rails workflows. Some skills also ship
extra files under `references/`, linked relatively from their `SKILL.md`.

## Requirements

The skills assume the following CLIs are installed (and authenticated where needed):

| Tool | Purpose | Install |
|------|---------|---------|
| [git](https://git-scm.com/) | Status, diffs, scoped local commits (`git-commit` skill) | Preinstalled with your OS, otherwise `brew install git` or `apt install git` |
| [redmine](https://github.com/aarondpn/redmine-cli) | Redmine issues, time entries, projects, wiki | `curl -fsSL https://raw.githubusercontent.com/aarondpn/redmine-cli/main/install.sh \| bash` then `redmine auth login` |
| [gh](https://cli.github.com/) | GitHub issues, PRs, Actions, releases | `brew install gh` or `apt install gh` then `gh auth login` |
| [glab](https://gitlab.com/gitlab-org/cli) | GitLab issues, MRs, pipelines, snippets | `brew install glab` or `apt install gitlab-cli` then `glab auth login` |
| [mise](https://mise.jdx.dev/) | Runtime/tool versions, env, tasks | `curl https://mise.jdx.dev/install.sh \| sh` (see install methods below) |

> Every directory under `skills/` is canonical in this repo, except
> `redmine-cli`, which is **referenced only** — its canonical copy lives at
> `~/.agents/skills/redmine-cli` and is not duplicated in this repo. See
> [redmine-cli](#redmine-cli) below.

## Skills

| Skill | Path | What it covers |
|-------|------|----------------|
| [github-cli](skills/github-cli/SKILL.md) | `skills/github-cli/` | `gh` auth, issues, PR create/review/merge, Actions (`gh run`), releases, code review flows |
| [gitlab-cli](skills/gitlab-cli/SKILL.md) | `skills/gitlab-cli/` | `glab` auth, issues, MR create/review/merge, pipelines (`glab ci`), snippets, `glab api` |
| [mise](skills/mise/SKILL.md) | `skills/mise/` | Version pinning with `.mise.toml`, `mise run/exec/tasks`, Ruby/Node stack for Rails |
| [rails-new-project](skills/rails-new-project/SKILL.md) | `skills/rails-new-project/` | Scaffold a new Rails app: detect/pin Ruby+Node+Rails, `rails new` (Postgres, devcontainer, propshaft), Redmine project + git remote, first boot + commit + push |
| [rails-feature](skills/rails-feature/SKILL.md) | `skills/rails-feature/` | Test-first feature/bugfix: detect RSpec vs Minitest from Gemfile, run via devcontainer/mise, failing test then implement, PR/MR, then update the Redmine ticket status |
| [rails-planning](skills/rails-planning/SKILL.md) | `skills/rails-planning/` | Split a large feature into small vertical slices, each with acceptance criteria + dependency links, created as real tracked tickets (redmine/gh/glab) |
| [backlog](skills/backlog/SKILL.md) | `skills/backlog/` | Turn an idea or feature into 10–15 vertical user stories: ask about stack + expensive decisions, no criteria, no estimates, walking skeleton first |
| [story](skills/story/SKILL.md) | `skills/story/` | Refine one story: 2–3 Given/When/Then criteria, split if it needs more, 5-bullet mini plan, output block ready for the tracker and for `/pair` |
| [pair](skills/pair/SKILL.md) | `skills/pair/` | Pair on a refined story: approve a test list, then one test → red → minimum code cycles, stop for decisions, check manual criteria, never commit |
| [devcontainers-cli](skills/devcontainers-cli/SKILL.md) | `skills/devcontainers-cli/` | Dev Containers CLI: build/up/exec/features/templates, validate `devcontainer.json` for the Rails + Postgres + mise stack |
| [git-commit](skills/git-commit/SKILL.md) | `skills/git-commit/` | Reviewed, scoped local commit: inspect state/diffs, scan for secrets, stage only authorized paths, apply message rules, keep hooks and signing, verify and report; never pushes. Ships `references/` (autonomous contract, message rules, validation scenarios) |
| [redmine-cli](https://github.com/aarondpn/redmine-cli) | `~/.agents/skills/redmine-cli` | Referenced only — use your existing local copy |

## Writing workflow: `/backlog` → `/story` → `/pair`

`backlog`, `story` and `pair` are one flow split into three steps, each one
handing its output to the next:

1. **`/backlog`** — slice the idea into vertical user stories (no criteria, no
   implementation).
2. **`/story`** — take one story, add 2–3 acceptance criteria + a mini plan, and
   wait for your approval.
3. **`/pair`** — build it: approved test list, then small test-first cycles. The
   AI writes code, you decide; it never commits.

All three set `disable-model-invocation: true`, so invoke them explicitly as
`/backlog`, `/story` and `/pair`. That is a Claude Code field: opencode ignores
unknown frontmatter fields, so it may also select them from the description.

`/story` and `/pair` never commit — `/pair` only proposes the message. To let the
agent create the commit itself, use
[git-commit](skills/git-commit/SKILL.md): it runs only on an explicit commit
request, commits once on a reviewed index, and never pushes.

## Install

opencode loads skills from `~/.agents/skills/<name>/SKILL.md`. Sync the in-repo
skills with:

```bash
./scripts/install-skills.sh
```

This creates a symlink for each directory under `skills/` into the target skills
directory (default `~/.agents/skills/`), so new skills are picked up automatically
on the next run and extra files such as `skills/git-commit/references/` travel with
their directory. Existing real directories are **never overwritten** — a conflicting
target is skipped with a warning. Pass `--force` to replace an existing symlink
(real directories are still never touched).

Customize the target directory:

```bash
SKILLS_DIR=~/.agents/skills ./scripts/install-skills.sh
```

To remove symlinks the repo no longer owns:

```bash
./scripts/install-skills.sh --prune
```

## Layout

```
README.md
scripts/install-skills.sh   # symlink sync into ~/.agents/skills/
skills/
  backlog/SKILL.md
  devcontainers-cli/SKILL.md
  git-commit/SKILL.md
  git-commit/references/autonomous.md
  git-commit/references/commit-messages.md
  git-commit/references/validation.md
  github-cli/SKILL.md
  gitlab-cli/SKILL.md
  mise/SKILL.md
  pair/SKILL.md
  rails-feature/SKILL.md
  rails-new-project/SKILL.md
  rails-planning/SKILL.md
  story/SKILL.md
```
