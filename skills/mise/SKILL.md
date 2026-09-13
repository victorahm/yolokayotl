---
name: mise
description: Use `mise` to manage tool versions and runtime environments for Ruby on Rails development. Activate when the user asks to install/pin/upgrade tool versions (Ruby, Node, etc.), read/write `.mise.toml` config, run tasks or scripts, set project-local env vars, or resolve "which ruby/node" issues. Also activate when the user says "mise", "rtx", "tool version", "asdf", or references the Rails runtime stack.
---

# mise

`mise` is the front-runner for runtime/tool-version management (an alternative to
asdf/rbenv/nvm), with built-in task running and env management. Use `mise --help`
and `mise <command> --help` for flags — this skill covers what the help cannot.

## Setup

- Install: `curl https://mise.jdx.dev/install.sh | sh` and add the shell hook to
  your `~/.bashrc`/`~/.zshrc` (`eval "$(mise activate bash)"`). If you use
  opencode's bundled shell, confirm PATH ordering (`which ruby` should resolve to
  a mise shim under `~/.local/share/mise/shims`).
- NOTE: the shim PATH typically lives at `~/.local/share/mise/shims`; verify with
  `which mise` and `echo $PATH`.

## Core Concepts & Files

- **`.mise.toml`** (project-local config) and **`~/.config/mise/config.toml`**
  (global defaults). Tool versions, tasks, and env live here.
- **Tools** state source: `mise current`, `mise ls`, `mise outdated`.
- **Tasks**: defined in `.mise.toml` under `[tasks.<name>]` or in
  `tools`-adjacent `tasks/` dirs. They're run with `mise run <task>`.

## Commands

- `mise install [tool@version]` — install (also reads `.mise.toml` and installs all
  declared tools). `mise install` with no args provisions the whole file.
- `mise use [tool@version [--global]]` — set the version in the local config
  (`--global` writes the global config). `mise use ruby@3.4.3`, `mise use node@22`.
- `mise current [tool]` — show what the project resolves for each tool.
- `mise exec [tool@version] -- <cmd>` — run a command with a specific tool version
  without mutating config. `mise x node -- node -v`.
- `mise run <task>` / `mise r` — run a project task from `.mise.toml`.
- `mise uninstall <tool@version>`, `mise outdated`, `mise upgrade [tool]`.
- `mise settings set` — runtime toggles e.g. `mise settings set experimental true`.
- `mise env` — print the env a tool would get (verification/debugging).

### Resolving "which ruby" confusion

Check `mise current ruby` and `resolve_proc bash -c 'which ruby'`. If Ruby from a
different manager (rbenv/asdf) shadows mise, fix PATH order or run the command via
`mise x` — never assume.

## Ruby on Rails specifics

- Pin per project (`.mise.toml`):
  `[tools] ruby = "3.4.3" bundler = "2" node = "22"`.
- The first `mise install` fetches/compiles the right Ruby via `mise`'s prebuilt
  builds (or asdf) and installs Bundler/gems inside its managed gem home.
- Run the whole Rails stack through mise so `bundle exec rails`, `bin/rails`, and
  JS tooling all share the pinned versions:
  `mise x -- bundle install`, `mise x -- bin/rails server`.
- Use `mise run` to turn one-liners into named tasks (e.g. `[tasks.db-migrate]
  run = "bundle exec rails db:migrate"`) so agents invoke consistent commands.

### Tasks (`.mise.toml`)

```toml
[tools]
ruby = "3.4.3"
node = "22"

[tasks.test]
run = "bundle exec rails test"

[tasks.lint]
run = "bundle exec rubocop"

[tasks.hello]
run = "echo hello"
```

Run them with `mise run test`, `mise run lint`. Tasks can take args and reference
env vars defined in `[env]`.

## Env vars (`[env]`)

```toml
[env]
DATABASE_URL = "postgres://localhost/yolokayotl_dev"
RAILS_ENV = "development"
```

These apply whenever mise is active for the project (the shell hook or `mise x`).
Debug with `mise env`.

## When Something Doesn't Work

- "Tool not found": run `mise ls` and `which <tool>` to compare versions. Confirm
  the version is resolvable: `mise ls-remote <tool>`.
- Task not found: `mise tasks` (prints configured tasks) instead of guessing names.
- Layout/symlink concern: `mise` installs into `~/.local/share/mise`; symlinks under
  `~/.local/share/mise/shims` and `~/.local/bin` must point at real binaries. If a
  shim errors, `mise reinstall <tool>`.
- Ask the user or run `mise <command> --help` rather than guessing flags.
