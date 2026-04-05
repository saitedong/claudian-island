#!/bin/bash
# Usage: island-notify.sh stop|notification
# Reads Claude Code hook JSON from stdin, sends to ClaudianIsland socket.

SOCKET="/tmp/claudian-island.sock"
TYPE="${1:-stop}"

# Read stdin (Claude Code hook payload)
INPUT="$(cat)"

if [[ "$TYPE" == "notification" ]]; then
    MSG="$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message', d.get('title', '通知')))" 2>/dev/null || echo "通知")"
    PAYLOAD="{\"type\":\"notification\",\"message\":\"$MSG\"}"
else
    PAYLOAD="{\"type\":\"stop\"}"
fi

# Send to socket (fire-and-forget, fail silently if app not running)
echo "$PAYLOAD" | nc -U "$SOCKET" 2>/dev/null || true
