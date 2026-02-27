# ai-agent-sandbox

一个面向新手的 AI 协同开发沙箱仓库，用于验证 **Agent Swarm v1** 工作流。

该仓库演示了完整最小闭环：

- 任务队列管理
- 任务状态流转（`todo -> running -> done/blocked`）
- Pull Request 协作流程
- CI 质量门禁
- Telegram 完成通知

---

## 你将学到什么

1. 如何在仓库中搭建可落地的 AI 协作结构。
2. 如何通过状态机管理任务执行过程。
3. 如何在合并前做基础质量校验。
4. 如何自动接收任务完成通知。

---

## 前置依赖

请先安装并确认：

- `git`
- `gh`（GitHub CLI）
- `bash`
- `python3`
- `jq`
- `node` + `npm`

快速检查：

```bash
git --version
gh --version
python3 --version
jq --version
node --version
```

登录 GitHub CLI：

```bash
gh auth login
```

---

## 仓库结构

```text
.github/
  workflows/ci.yml                  # CI 检查流程
  pull_request_template.md          # PR 模板

.clawdbot/
  active-tasks.json                 # 任务状态单一真相源
  prompts/
    orchestrator-v1.md              # 总控提示词
    task-template.md                # 任务模板
  scripts/
    update-task-status.sh           # 状态更新脚本
    run-task.sh                     # 任务执行器（含失败兜底）
    notify-done.sh                  # 完成通知（Telegram/stdout）
  logs/

.env.example                        # 环境变量模板
.markdownlint.json                  # Markdown 规范配置
```

---

## 快速开始

1. 克隆仓库。

   ```bash
   git clone https://github.com/gyckey/ai-agent-sandbox.git
   cd ai-agent-sandbox
   ```

2. 准备环境变量文件。

   ```bash
   cp .env.example .env
   ```

3. （可选）在 `.env` 中配置 Telegram 通知。

   ```env
   TG_BOT_TOKEN=你的bot_token
   TG_CHAT_ID=你的chat_id
   ```

4. 创建功能分支。

   ```bash
   git checkout -b feat/your-task-name
   ```

---

## 核心流程（新手版）

### 步骤 1：新增或选择任务

编辑 `.clawdbot/active-tasks.json`，每个任务应包含：

- `id`
- `title`
- `status`（`todo` / `running` / `done` / `blocked`）
- `priority`

示例：

```json
{
  "id": "task-003-ci",
  "title": "Add basic GitHub Actions CI",
  "status": "todo",
  "priority": "high"
}
```

### 步骤 2：执行任务

```bash
./.clawdbot/scripts/run-task.sh task-003-ci "Add basic GitHub Actions CI"
```

执行器会自动：

1. 把任务状态改为 `running`
2. 执行任务逻辑（当前为示例逻辑）
3. 成功后改为 `done`
4. 失败时改为 `blocked`
5. 发送完成通知（若已配置 Telegram）

### 步骤 3：提交并推送

```bash
git add .
git commit -m "feat: complete task-003-ci"
git push -u origin feat/your-task-name
```

### 步骤 4：创建 PR

```bash
gh pr create \
  --title "feat: complete task-003-ci" \
  --body "Implements task-003-ci using sandbox workflow." \
  --base main \
  --head feat/your-task-name
```

### 步骤 5：合并并同步主分支

```bash
gh pr merge --squash --delete-branch
git checkout main
git pull
```

---

## 脚本说明

### `update-task-status.sh`

更新任务状态：

```bash
./.clawdbot/scripts/update-task-status.sh task-003-ci running
```

### `run-task.sh`

串联任务状态流转：

- `todo/running -> running`
- 执行任务
- 成功 -> `done`
- 失败 -> `blocked`

```bash
./.clawdbot/scripts/run-task.sh task-003-ci "Add basic GitHub Actions CI"
```

### `notify-done.sh`

发送完成通知：

- `.env` 配置完整：发 Telegram
- 未配置：输出到终端

```bash
./.clawdbot/scripts/notify-done.sh task-003-ci "Add basic GitHub Actions CI"
```

---

## CI 与质量门禁

`.github/workflows/ci.yml` 默认执行：

- Markdown lint
- `active-tasks.json` 格式校验
- Shell 语法检查
- Shellcheck

本地可先做快速预检：

```bash
python3 -m json.tool .clawdbot/active-tasks.json > /dev/null
bash -n .clawdbot/scripts/*.sh
```

---

## 常见问题

### 1）GitHub Actions 提示 workflow YAML 无效

原因：`ci.yml` 缩进或语法错误。

处理：严格使用 2 空格缩进，逐段检查。

### 2）`Markdown lint (strict)` 失败

原因：文档格式不符合规范（空行、列表、行长等）。

处理：

```bash
markdownlint "**/*.md"
```

按输出修复后重新 push。

### 3）通知脚本回退到 stdout

原因：`.env` 缺失或变量值不完整。

处理：确认仓库根目录存在 `.env`，且 `TG_BOT_TOKEN`、`TG_CHAT_ID` 为真实值。

---

## 下一步升级建议

1. 把 `run-task.sh` 的示例逻辑替换为真实 agent 调用。
2. 将 `blocked` 原因写回 JSON。
3. 增加日报脚本（完成任务数、PR 数、blocked 数）。
4. 加入任务路由（后端/文档/UI 分配不同 agent）。

---

## 路线图

- [x] 最小任务队列 + 状态机
- [x] CI 质量检查 + PR 模板
- [x] Telegram 通知（`.env` 自动加载）
- [ ] 接入真实多 Agent 执行
- [ ] 增加指标看板与日报
