#!/bin/bash
# ClaudianIsland 安装脚本
# 在目标 Mac 上运行：bash install.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== ClaudianIsland 安装程序 ==="
echo ""

# 1. 安装 app
echo "▶ 安装 ClaudianIsland.app ..."
mkdir -p ~/Applications
cp -r "$SCRIPT_DIR/ClaudianIsland.app" ~/Applications/
# 首次运行需要绕过 Gatekeeper（未签名 app）
xattr -cr ~/Applications/ClaudianIsland.app 2>/dev/null || true
echo "  ✓ ~/Applications/ClaudianIsland.app"

# 2. 安装 hook 脚本
echo "▶ 安装 hook 脚本 ..."
mkdir -p ~/.claude/scripts
cp "$SCRIPT_DIR/scripts/island-notify.sh"     ~/.claude/scripts/
cp "$SCRIPT_DIR/scripts/island-permission.py" ~/.claude/scripts/
chmod +x ~/.claude/scripts/island-notify.sh
chmod +x ~/.claude/scripts/island-permission.py
echo "  ✓ ~/.claude/scripts/island-notify.sh"
echo "  ✓ ~/.claude/scripts/island-permission.py"

# 3. 安装 LaunchAgent（开机自启）
echo "▶ 配置开机自启 ..."
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.jeff.claudian-island.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jeff.claudian-island</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/saitedong/Applications/ClaudianIsland.app/Contents/MacOS/ClaudianIsland</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/claudian-island.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/claudian-island.log</string>
</dict>
</plist>
EOF
launchctl unload ~/Library/LaunchAgents/com.jeff.claudian-island.plist 2>/dev/null || true
launchctl load   ~/Library/LaunchAgents/com.jeff.claudian-island.plist
echo "  ✓ LaunchAgent 已加载"

# 4. 等 app 启动，测试 socket
echo ""
echo "▶ 启动测试 ..."
sleep 3
if echo '{"type":"stop"}' | nc -U /tmp/claudian-island.sock 2>/dev/null; then
    echo "  ✓ Socket 通信正常，安装成功！"
else
    echo "  ⚠ Socket 未响应。请手动打开 ~/Applications/ClaudianIsland.app"
    echo "    首次打开：右��� → 打开 → 点「打开」绕过 Gatekeeper"
fi

echo ""
echo "=== 安装完成 ==="
echo ""
echo "⚠ 还需要手动完成一��："
echo "   系统设置 → 隐私与安全性 → 屏幕录制"
echo "   → 允许 ClaudianIsland（用于检测外接显示器状态）"
echo ""
echo "Vault 的 .claude/settings.json 里的 hooks 配置已通过 iCloud 同步，无需重复配置。"
