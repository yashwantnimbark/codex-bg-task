# codex-bg-task

Local background jobs that wake your running OpenAI Codex CLI session.

`codex-bg-task` is a small tmux-based harness for people who run Codex in a
terminal and want long-running local work to re-enter the same conversation
later. It can run commands, timers, and GitHub PR watchers in detached tmux
jobs. When a job finishes, it appends a structured `[BG]` event to
`~/.codex/feed.md`; a lightweight injector service delivers that event into the
target Codex tmux pane.

This is intentionally boring shell. No daemon framework, no model polling, no
extra agent sitting around burning tokens.

## Why

Codex is great at active work, but waiting is a poor use of an interactive
agent. This project gives you a local "wake me when that finishes" loop:

```sh
codex-bg run -- pnpm test
codex-bg sleep 10m --message "check the staging build"
codex-bg watch-pr 123 60 60
```

When the task completes, Codex receives a follow-up like:

```text
[BG] event_id=20260524T160657-001 session=codex action=command-finished job=bg-... status=passed exit=0 log=...
```

## Requirements

- macOS or Linux
- Bash
- tmux
- OpenAI Codex CLI on `PATH`
- Optional for `watch-pr`: GitHub CLI `gh` and `jq`

The scripts use portable macOS-friendly shell forms such as
`date '+%Y-%m-%dT%H:%M:%S%z'` and `tail -F -n 0`.

## Install

Clone the repo, then install the scripts into a directory on your `PATH`:

```sh
./install.sh
```

By default this installs to `~/.local/bin`. To choose a different prefix:

```sh
PREFIX="$HOME/bin" ./install.sh
```

## Quick Start

Start Codex inside tmux:

```sh
codex-tmux
```

Start a named session with Codex's sandbox/approval bypass flag:

```sh
codex-tmux --yolo work
```

`--yolo` is a compatibility shortcut in this wrapper. It is passed to current
Codex as `--dangerously-bypass-approvals-and-sandbox`.

In another terminal, send a test event:

```sh
codex-bg feed "action=note message=hello from the background"
```

Run a command in the background and wake Codex when it finishes:

```sh
codex-bg run --action tests-finished -- pnpm test
```

Start a timer:

```sh
codex-bg sleep 10m --action follow-up --message "check CI"
```

Watch a GitHub PR for new reviews, comments, or failed checks:

```sh
codex-bg watch-pr 123 60 60
```

Inspect jobs and delivery state:

```sh
codex-bg status
codex-feed-status codex
```

## Multiple Codex Sessions

The default Codex session is named `codex`.

Start a named session:

```sh
codex-tmux work
```

Target that session:

```sh
codex-bg run --session work --action build-finished -- npm run build
codex-bg feed --session work "action=note message=ready"
```

Unscoped feed events are delivered only to the default `codex` session.

If a tmux session already exists, `codex-tmux` attaches to it and does not
restart Codex with new flags. To change startup flags, exit Codex in that tmux
session or kill the session first, then start it again.

## How It Works

Files live under `~/.codex`:

- `~/.codex/feed.md`: append-only event feed
- `~/.codex/monitors/*.log`: job and injector logs
- `~/.codex/monitors/bg-*.{meta,log,result,pid,worker.sh}`: job metadata

Core commands:

- `codex-tmux`: launch or attach to a Codex tmux session and start delivery
- `codex-bg`: create jobs, timers, PR watchers, and one-line events
- `codex-feed-injector`: tail the feed and submit `[BG]` events into Codex
- `codex-feed-status`: inspect delivery state
- `codex-feed-restart`: repair/restart delivery
- `codex-feed-stop`: stop delivery

The injector pastes the full event into Codex with a tmux paste buffer and
submits with `Tab`. This avoids the common terminal/TUI problem where `Enter`
can create a multiline edit instead of sending the prompt.

## Safety Notes

This project automates a terminal UI. That is useful, but inherently more
brittle than an official API. Keep event messages short and structured. Do not
use BG events to perform destructive work without normal Codex/user review.

The scripts do not need network access except for commands you explicitly run,
such as `gh pr view` in `codex-bg watch-pr`.

## Development

Run the local tests:

```sh
./test/smoke.sh
```

The smoke test uses an isolated temporary `HOME` and a throwaway tmux shell
session. It does not touch your live `~/.codex` feed or Codex session.

## License

MIT
