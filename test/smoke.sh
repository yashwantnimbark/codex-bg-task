#!/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATH="$ROOT/bin:$PATH"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || fail "missing dependency: $1"
}

need bash
need tmux

for script in "$ROOT"/bin/codex-*; do
  bash -n "$script" || fail "syntax check failed: $script"
done

if [ -n "${PRIVATE_PATTERN:-}" ]; then
  if grep -ERn "$PRIVATE_PATTERN" "$ROOT" >/dev/null; then
    grep -ERn "$PRIVATE_PATTERN" "$ROOT" >&2
    fail "private/project-specific text found"
  fi
fi

TEST_HOME="$(mktemp -d /tmp/codex-bg-task-home.XXXXXX)"
SESSION="codex-bg-task-smoke-$$"
EVENT="session=$SESSION action=smoke message=hello-$(date +%s)"

cleanup() {
  HOME="$TEST_HOME" "$ROOT/bin/codex-feed-stop" "$SESSION" --quiet >/dev/null 2>&1 || true
  tmux kill-session -t "$SESSION" 2>/dev/null || true
  rm -rf "$TEST_HOME"
}
trap cleanup EXIT INT TERM

tmux new-session -d -s "$SESSION" "bash --noprofile --norc"
sleep 0.3

HOME="$TEST_HOME" "$ROOT/bin/codex-feed-restart" "$SESSION" >/dev/null
sleep 0.5
printf '[BG] %s\n' "$EVENT" >> "$TEST_HOME/.codex/feed.md"
sleep 1.5

CAPTURE="$(tmux capture-pane -p -J -t "$SESSION:0.0" -S -80)"
printf '%s\n' "$CAPTURE" | grep -E -q "\\[BG\\].*$EVENT" || {
  printf '%s\n' "$CAPTURE" >&2
  fail "event was not delivered to tmux pane"
}

echo "ok"
