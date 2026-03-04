# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Daily report script with Telegram delivery ([#13])
- Parallel queue runner for concurrent task execution ([#11])
- Telegram notification for completed tasks ([#9])
- Task runner with status transitions and failure fallback ([#8])
- Done notification script ([#5])
- Task status transition script (`update-task-status.sh`) ([#4])
- Initial multi-task queue (`active-tasks.json`) ([#3])
- Quick start section in README ([#2])
- Week-1 project roadmap ([#1])
- Orchestrator prompt and task registry
- Chinese README for beginner onboarding
- Pull request template with Definition of Done checklist ([#7])

### Changed

- Refactored inline Python out of shell scripts; added retry and blocked-reason flow ([#12])

### Fixed

- Mark dry-run tasks as blocked with explicit reason
- Restore Python indentation in task scripts and verify routing flow
- Correct workflow YAML indentation

### CI

- Hardened checks with shellcheck and strict markdown/JSON validation ([#6])

[#1]: https://github.com/gyckey/ai-agent-sandbox/pull/1
[#2]: https://github.com/gyckey/ai-agent-sandbox/pull/2
[#3]: https://github.com/gyckey/ai-agent-sandbox/pull/3
[#4]: https://github.com/gyckey/ai-agent-sandbox/pull/4
[#5]: https://github.com/gyckey/ai-agent-sandbox/pull/5
[#6]: https://github.com/gyckey/ai-agent-sandbox/pull/6
[#7]: https://github.com/gyckey/ai-agent-sandbox/pull/7
[#8]: https://github.com/gyckey/ai-agent-sandbox/pull/8
[#9]: https://github.com/gyckey/ai-agent-sandbox/pull/9
[#11]: https://github.com/gyckey/ai-agent-sandbox/pull/11
[#12]: https://github.com/gyckey/ai-agent-sandbox/pull/12
[#13]: https://github.com/gyckey/ai-agent-sandbox/pull/13
