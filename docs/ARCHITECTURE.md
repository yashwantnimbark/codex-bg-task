# Architecture

`codex-bg-task` has three moving parts:

1. A Codex tmux session, normally started with `codex-tmux`.
2. Background jobs started by `codex-bg`.
3. A per-session injector service started by `codex-feed-restart`.

Jobs append one-line events to `~/.codex/feed.md`. Each event is plain text and
usually starts with `[BG]`:

```text
[BG] session=codex action=tests-finished job=bg-... status=passed exit=0 log=...
```

The injector tails the feed and filters events by `session=`. Matching events
are delivered into the active tmux pane for that Codex session.

## Delivery

The injector avoids character-by-character typing. It loads the event into a
tmux buffer, pastes it into the Codex pane with bracketed paste enabled, then
sends `Tab` to submit the follow-up input.

That sequence is intentionally conservative:

- paste buffer keeps long URLs and structured messages intact
- `Tab` submits Codex follow-up input reliably in tmux
- `Enter` is avoided because it can create multiline input in the Codex TUI

## State Files

All state lives under `~/.codex`:

- `feed.md`: append-only event feed
- `monitors/feed-injector-<session>.*`: injector PID, lock, target, state, log
- `monitors/bg-*.*`: background job metadata, logs, result, PID, worker script

No long-running process is started outside tmux. Stopping the tmux service
session stops the injector.

## Failure Modes

- If the target Codex tmux session is gone, delivery stops.
- If the target pane is stale, the injector resolves the active pane again.
- If a duplicate injector starts, a lock file prevents two services from
  delivering the same feed line to one session.
- If Codex changes TUI submission keys, `send_to_codex` in
  `bin/codex-feed-injector` is the likely patch point.
