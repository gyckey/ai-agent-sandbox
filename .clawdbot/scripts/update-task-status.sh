#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
NEW_STATUS="${2:?new status required}" # todo|running|done|blocked

python3 - <<'PY' "$TASK_ID" "$NEW_STATUS"
import json,sys
task_id=sys.argv[1]
new_status=sys.argv[2]
path=".clawdbot/active-tasks.json"
with open(path,"r",encoding="utf-8") as f:
data=json.load(f)
for t in data:
if t.get("id")==task_id:
t["status"]=new_status
break
with open(path,"w",encoding="utf-8") as f:
json.dump(data,f,ensure_ascii=False,indent=2)
print(f"updated {task_id} -> {new_status}")
PY