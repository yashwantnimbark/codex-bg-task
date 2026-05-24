# Contributing

Thanks for helping improve `codex-bg-task`.

Please keep the project small and dependency-light. The goal is a practical
local shell harness, not a service framework.

Before opening a pull request:

1. Run `./test/smoke.sh`.
2. Run `bash -n bin/* install.sh test/smoke.sh`.
3. Avoid project-specific paths, company names, or private workflow details in
   examples and tests.

Bug reports are most helpful when they include:

- operating system
- tmux version
- Codex CLI version
- whether the event reached the input box
- whether it submitted or stayed as editable text
