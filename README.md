# ai-agent-sandbox

A beginner-friendly sandbox to validate an AI-orchestrated development workflow.

This repository demonstrates a practical **Agent Swarm v1** loop:

- task queue management
- task state transitions (`todo -> running -> done/blocked`)
- pull request workflow
- CI quality checks
- Telegram notifications on completion

---

## What You Will Learn

1. How to structure a small AI delivery system in a repo.
2. How to run tasks through a predictable state machine.
3. How to enforce basic quality gates before merge.
4. How to receive automated task completion notifications.

---

## Prerequisites

Install and verify these tools first:

- `git`
- `gh` (GitHub CLI)
- `bash`
- `python3`
- `jq`
- `shfmt`
- `node` + `npm` (for markdown lint in CI)

Quick checks:

```bash
git --version
gh --version
python3 --version
jq --version
shfmt --version
node --version
```

Authenticate GitHub CLI:

```bash
gh auth login
```

---

## Repository Structure

```text
.github/
  workflows/ci.yml                  # CI checks
  pull_request_template.md          # PR quality template

.clawdbot/
  active-tasks.json                 # single source of truth for task states
  prompts/
    orchestrator-v1.md              # orchestrator instructions
    task-template.md                # task drafting template
  scripts/
    update-task-status.sh           # status updater
    run-task.sh                     # task runner (with fallback)
    notify-done.sh                  # Telegram (or stdout) notifier
    format-shell.sh                 # shell formatter (writes)
    check-shell-format.sh           # shell formatter check (diff only)
    install-githooks.sh             # setup repo-local git hooks
  logs/

.env.example                        # env template for Telegram
.markdownlint.json                  # markdown lint settings
```

---

## Quick Start

1. Clone repository.

   ```bash
   git clone https://github.com/gyckey/ai-agent-sandbox.git
   cd ai-agent-sandbox
   ```

2. Prepare env file.

   ```bash
   cp .env.example .env
   ```

3. (Optional) Configure Telegram notification values in `.env`.

   ```env
   TG_BOT_TOKEN=your_bot_token
   TG_CHAT_ID=your_chat_id
   ```

4. Create your feature branch.

   ```bash
   git checkout -b feat/your-task-name
   ```

---

## Core Workflow (Newbie Version)

### Step 1: Add or pick a task

Edit `.clawdbot/active-tasks.json` and ensure each task has:

- `id`
- `title`
- `status` (`todo` / `running` / `done` / `blocked`)
- `priority`

Example:

```json
{
  "id": "task-003-ci",
  "title": "Add basic GitHub Actions CI",
  "status": "todo",
  "priority": "high"
}
```

### Step 2: Run a task

```bash
./.clawdbot/scripts/run-task.sh task-003-ci "Add basic GitHub Actions CI"
```

What happens:

1. status becomes `running`
2. task logic executes (currently minimal demo logic)
3. status becomes `done` on success
4. status becomes `blocked` on failure (trap fallback)
5. notification is sent (Telegram if env configured)

### Step 3: Commit and push

```bash
git add .
git commit -m "feat: complete task-003-ci"
git push -u origin feat/your-task-name
```

### Step 4: Open PR

```bash
gh pr create \
  --title "feat: complete task-003-ci" \
  --body "Implements task-003-ci using sandbox workflow." \
  --base main \
  --head feat/your-task-name
```

### Step 5: Merge and sync

After checks pass and review is done:

```bash
gh pr merge --squash --delete-branch
git checkout main
git pull
```

---

## Scripts Reference

### `update-task-status.sh`

Updates one task state in `.clawdbot/active-tasks.json`.

```bash
./.clawdbot/scripts/update-task-status.sh task-003-ci running
```

### `run-task.sh`

Wrapper script that drives the full transition flow:

- `todo/running -> running`
- execute task logic
- success -> `done`
- failure -> `blocked`

```bash
./.clawdbot/scripts/run-task.sh task-003-ci "Add basic GitHub Actions CI"
```

### `notify-done.sh`

Sends completion notification.

- uses Telegram if `TG_BOT_TOKEN` + `TG_CHAT_ID` are present
- otherwise prints to stdout

```bash
./.clawdbot/scripts/notify-done.sh task-003-ci "Add basic GitHub Actions CI"
```

### `format-shell.sh`

Formats all shell scripts under `.clawdbot/scripts/*.sh`.

```bash
./.clawdbot/scripts/format-shell.sh
```

### `check-shell-format.sh`

Checks shell formatting (CI-safe, no file rewrite).

```bash
./.clawdbot/scripts/check-shell-format.sh
```

### `install-githooks.sh`

Installs repository-local hooks (`core.hooksPath=.githooks`).

```bash
./.clawdbot/scripts/install-githooks.sh
```

---

## CI and Quality Gates

This repo uses `.github/workflows/ci.yml` to run:

- Markdown lint
- JSON validation for `active-tasks.json`
- shell format check (`shfmt` diff)
- shell syntax check
- shellcheck

Recommended local setup and pre-check:

```bash
./.clawdbot/scripts/install-githooks.sh
./.clawdbot/scripts/format-shell.sh
./.clawdbot/scripts/check-shell-format.sh
python3 -m json.tool .clawdbot/active-tasks.json > /dev/null
bash -n .clawdbot/scripts/*.sh
```

---

## Common Issues

### 1) GitHub Action says invalid workflow YAML

Cause: indentation or syntax error in `.github/workflows/ci.yml`.

Fix: use 2-space YAML indentation and validate carefully.

### 2) `Markdown lint (strict)` failed

Cause: markdown formatting violations (blank lines, list style, long lines, etc.).

Fix:

```bash
markdownlint "**/*.md"
```

Then fix reported files and push again.

### 3) `Shell format check` failed in CI

Cause: one or more `.clawdbot/scripts/*.sh` files are not shfmt-formatted.

Fix:

```bash
./.clawdbot/scripts/format-shell.sh
git add .clawdbot/scripts/*.sh
git commit -m "chore: format shell scripts"
```

### 4) Telegram notification falls back to stdout

Cause: missing or invalid `.env` values.

Fix:

- ensure `.env` exists at repo root
- ensure `TG_BOT_TOKEN` and `TG_CHAT_ID` are real values

---

## Suggested Next Upgrades

1. Replace demo task execution in `run-task.sh` with real agent calls.
2. Persist `blocked` reason into task JSON.
3. Add daily summary script (completed tasks, PR count, blocked count).
4. Add role-based routing (e.g., backend/docs/UI agents).

---

## Project Roadmap

- [x] Build minimal task queue and state transitions.
- [x] Add CI checks and PR template.
- [x] Add Telegram notification with `.env` auto-load.
- [ ] Integrate real multi-agent execution.
- [ ] Add metrics dashboard and daily report.
