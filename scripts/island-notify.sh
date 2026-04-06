#!/bin/bash
# Usage: island-notify.sh stop|notification
# Reads Claude Code hook JSON from stdin, sends to ClaudianIsland socket.

SOCKET="/tmp/claudian-island.sock"
LOG="/tmp/claudian-island-hook.log"
TYPE="${1:-stop}"

# Read stdin (Claude Code hook payload)
INPUT="$(cat)"

# Log every invocation with timestamp and raw payload
echo "[$(date '+%Y-%m-%dT%H:%M:%S')] notify type=$TYPE input=$INPUT env_hook_input=$CLAUDE_HOOK_INPUT" >> "$LOG"

if [[ "$TYPE" == "notification" ]]; then
    MSG="$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message', d.get('title', '通知')))" 2>/dev/null || echo "通知")"
    PAYLOAD="{\"type\":\"notification\",\"message\":\"$MSG\"}"
else
    # 传 session_id 给岛屿，用于同 session 去重
    SID="$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")"
    PAYLOAD="{\"type\":\"stop\",\"session_id\":\"$SID\"}"
fi

# Send to socket (fire-and-forget, fail silently if app not running)
echo "$PAYLOAD" | nc -U "$SOCKET" 2>/dev/null || true
