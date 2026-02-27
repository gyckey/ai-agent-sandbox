# ai-agent-sandbox

Test repository for validating an AI-orchestrated development workflow.

## Goals

- Verify local agent orchestration setup.
- Test branch/PR flow.
- Record experiments and outcomes.

## Quick Start

1. Clone repository.

   ```bash
   git clone https://github.com/gyckey/ai-agent-sandbox.git
   cd ai-agent-sandbox
   ```

1. Create `.clawdbot` base structure.

   ```bash
   mkdir -p .clawdbot/{prompts,scripts,logs}
   echo "[]" > .clawdbot/active-tasks.json
   ```

1. Create a feature branch and commit changes.

   ```bash
   git checkout -b feat/your-task-name
   git add .
   git commit -m "docs: add quick start section"
   git push -u origin feat/your-task-name
   ```

1. Open a pull request.

   ```bash
   gh pr create \
     --title "docs: add quick start section" \
     --body "Add minimal quick start instructions." \
     --base main \
     --head feat/your-task-name
   ```

## Project Roadmap (Week 1)

- [ ] Setup orchestrator structure.
- [ ] Create first PR workflow test.
- [ ] Add basic automation scripts.
