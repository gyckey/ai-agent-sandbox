#!/usr/bin/env python3
import json
import sys
from datetime import datetime, timezone

if len(sys.argv) < 3:
    raise SystemExit("usage: update_task_status.py <task_id> <new_status> [reason]")

task_id = sys.argv[1]
new_status = sys.argv[2]
reason = sys.argv[3] if len(sys.argv) > 3 else ""
path = ".clawdbot/active-tasks.json"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

found = False
for t in data:
    if t.get("id") == task_id:
        t["status"] = new_status
        t["updatedAt"] = datetime.now(timezone.utc).isoformat()
        if new_status == "blocked":
            t["blockedReason"] = reason or "unknown error"
        else:
            t.pop("blockedReason", None)
        found = True
        break

if not found:
    raise SystemExit(f"task not found: {task_id}")

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"updated {task_id} -> {new_status}")