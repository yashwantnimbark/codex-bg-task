# Publishing Checklist

Before publishing:

1. Run `./test/smoke.sh`.
2. Search for private paths or project names, using patterns that match your
   machine or unpublished projects:

   ```sh
   grep -ERn '<your-private-patterns>' .
   ```

   You can also pass that check into the smoke test:

   ```sh
   PRIVATE_PATTERN='<your-private-patterns>' ./test/smoke.sh
   ```

3. Confirm the scripts are executable:

   ```sh
   find bin -type f -print -exec test -x {} \;
   ```

4. Create a fresh GitHub repository.
5. Push:

   ```sh
   git remote add origin git@github.com:<you>/codex-bg-task.git
   git branch -M main
   git push -u origin main
   ```

Suggested repository description:

> Local background jobs that wake your running OpenAI Codex CLI tmux session.
