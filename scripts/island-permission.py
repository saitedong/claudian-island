#!/usr/bin/env python3
"""
PermissionRequest hook for ClaudianIsland.
- 通知岛屿有工具需要审批（显示提示让用户去 Obsidian）
- 立即返回 ask，让 Claudian 的内置 UI 处理实际审批
- 不阻塞，不做决策
"""
import sys
import json
import socket
import uuid
import datetime

SOCKET_PATH = "/tmp/claudian-island.sock"
LOG_PATH = "/tmp/claudian-island-hook.log"

def log(msg):
    ts = datetime.datetime.now().isoformat(timespec="seconds")
    with open(LOG_PATH, "a") as f:
        f.write(f"[{ts}] {msg}\n")

def main():
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        hook_input = {}

    tool_name = hook_input.get("tool_name", hook_input.get("tool", "unknown"))
    request_id = str(uuid.uuid4())
    log(f"hook fired: tool={tool_name} id={request_id}")

    # AskUserQuestion: 岛屿显示"有提问待回答"，立即放行
    if tool_name == "AskUserQuestion":
        msg_type = "question_pending"
    else:
        msg_type = "permission_pending"

    # 通知岛屿（fire-and-forget）
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH)
        sock.sendall((json.dumps({
            "type": msg_type,
            "tool": tool_name,
            "id": request_id
        }) + "\n").encode("utf-8"))
        sock.close()
    except Exception:
        pass

    # AskUserQuestion → allow（让 Claude Code 直接执行弹问题 UI）
    # 其他工具 → ask（让 Claudian 自己的审批 UI 处理）
    decision = "allow" if tool_name == "AskUserQuestion" else "ask"
    log(f"outputting: decision={decision}")
    print(json.dumps({"decision": decision}))

if __name__ == "__main__":
    main()
