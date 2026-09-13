# yolokayotl

Personal collection of agent skills for Ruby on Rails development. Each skill is a
directory containing a `SKILL.md` (with opencode-style frontmatter) that teaches a
CLI agent how to drive a specific tool for Rails workflows.

## Requirements

The skills assume the following CLIs are installed and authenticated:

| Tool | Purpose | Install |
|------|---------|---------|
| [redmine](https://github.com/aarondpn/redmine-cli) | Redmine issues, time entries, projects, wiki | `curl -fsSL https://raw.githubusercontent.com/aarondpn/redmine-cli/main/install.sh \| bash` then `redmine auth login` |
| [gh](https://cli.github.com/) | GitHub issues, PRs, Actions, releases | `brew install gh` or `apt install gh` then `gh auth login` |
| [glab](https://gitlab.com/gitlab-org/cli) | GitLab issues, MRs, pipelines, snippets | `brew install glab` or `apt install gitlab-cli` then `glab auth login` |
| [mise](https://mise.jdx.dev/) | Runtime/tool versions, env, tasks | `curl https://mise.jdx.dev/install.sh \| sh` (see install methods below) |

> The canonical skills are `github-cli`, `gitlab-cli`, and `mise`. The
> `redmine-cli` skill is **referenced only** — its canonical copy lives at
> `~/.agents/skills/redmine-cli` and is not duplicated in this repo. See
> [redmine-cli](#redmine-cli) below.

## Skills

| Skill | Path | What it covers |
|-------|------|----------------|
| [github-cli](skills/github-cli/SKILL.md) | `skills/github-cli/` | `gh` auth, issues, PR create/review/merge, Actions (`gh run`), releases, code review flows |
| [gitlab-cli](skills/gitlab-cli/SKILL.md) | `skills/gitlab-cli/` | `glab` auth, issues, MR create/review/merge, pipelines (`glab ci`), snippets, `glab api` |
| [mise](skills/mise/SKILL.md) | `skills/mise/` | Version pinning with `.mise.toml`, `mise run/exec/tasks`, Ruby/Node stack for Rails |
| [redmine-cli](https://github.com/aarondpn/redmine-cli) | `~/.agents/skills/redmine-cli` | Referenced only — use your existing local copy |

## Install

opencode loads skills from `~/.agents/skills/<name>/SKILL.md`. Sync the in-repo
skills with:

```bash
./scripts/install-skills.sh
```

This creates a symlink for each directory under `skills/` into the target skills
directory (default `~/.agents/skills/`). Existing real directories are **never
overwritten** — a conflicting target is skipped with a warning. Pass `--force` to
replace an existing symlink (real directories are still never touched).

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
  github-cli/SKILL.md
  gitlab-cli/SKILL.md
  mise/SKILL.md
```
