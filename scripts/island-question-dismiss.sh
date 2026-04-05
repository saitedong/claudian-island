#!/bin/bash
# PostToolUse hook: 当 AskUserQuestion 工具执行完毕时，通知岛屿清除 question 状态。
# Usage: cat | bash island-question-dismiss.sh

SOCKET="/tmp/claudian-island.sock"
INPUT="$(cat)"
TOOL="$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)"

if [[ "$TOOL" == "AskUserQuestion" ]]; then
    echo '{"type":"dismiss_question"}' | nc -U "$SOCKET" 2>/dev/null || true
fi
