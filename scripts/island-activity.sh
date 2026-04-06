#!/bin/bash
# PreToolUse hook: 告诉岛屿 Claude 正在调用工具（还在干活）。
# 用于取消 pending 的 ✓ 弹窗。Fire-and-forget。
echo '{"type":"tool_activity"}' | nc -U /tmp/claudian-island.sock 2>/dev/null || true
