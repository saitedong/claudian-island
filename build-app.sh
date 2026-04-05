#!/bin/bash
# Builds ClaudianIsland.app from Swift Package and launches it.
# Run once after building to install to /Applications or ~/Applications.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "▶ Building ClaudianIsland..."
swift build -c release 2>&1

BINARY=".build/release/ClaudianIsland"
APP_DIR="ClaudianIsland.app/Contents/MacOS"
RESOURCES_DIR="ClaudianIsland.app/Contents/Resources"

echo "▶ Packaging into .app bundle..."
mkdir -p "$APP_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$BINARY" "$APP_DIR/ClaudianIsland"

# Info.plist — no dock icon, background app
cat > "ClaudianIsland.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>ClaudianIsland</string>
    <key>CFBundleIdentifier</key>
    <string>com.jeff.claudian-island</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>ClaudianIsland</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>ClaudianIsland needs this to focus Obsidian when you tap a notification.</string>
</dict>
</plist>
EOF

echo "✓ Built: $SCRIPT_DIR/ClaudianIsland.app"
echo ""
echo "Next steps:"
echo "  1. Copy hooks scripts:  cp scripts/island-notify.sh scripts/island-permission.py ~/.claude/scripts/"
echo "  2. chmod +x ~/.claude/scripts/island-notify.sh"
echo "  3. Install app:  cp -r ClaudianIsland.app ~/Applications/"
echo "  4. Launch:  open ~/Applications/ClaudianIsland.app"
echo "  5. Test:  echo '{\"type\":\"stop\"}' | nc -U /tmp/claudian-island.sock"
