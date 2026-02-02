#!/bin/bash
# Show detailed information about a specific plugin

if [ -z "$1" ]; then
  echo "Usage: $0 <plugin-name>"
  echo "Example: $0 oh-my-claudecode@omc"
  exit 1
fi

PLUGIN_KEY="$1"

echo "🔍 Plugin Information: $PLUGIN_KEY"
echo "========================================"

jq -r --arg key "$PLUGIN_KEY" '
  .plugins[$key][0] |
  "Version: \(.version)\n" +
  "Install Path: \(.installPath)\n" +
  "Installed At: \(.installedAt)\n" +
  "Last Updated: \(.lastUpdated)\n" +
  "Git Commit: \(.gitCommitSha)"
' ~/.claude/plugins/installed_plugins.json

# Check if plugin directory exists
INSTALL_PATH=$(jq -r --arg key "$PLUGIN_KEY" '.plugins[$key][0].installPath' ~/.claude/plugins/installed_plugins.json)

if [ -d "$INSTALL_PATH" ]; then
  echo ""
  echo "📁 Directory Contents:"
  ls -lh "$INSTALL_PATH" | head -20

  # Check for skills directory
  if [ -d "$INSTALL_PATH/skills" ]; then
    echo ""
    echo "🎯 Skills Provided:"
    ls "$INSTALL_PATH/skills" 2>/dev/null || echo "  (none)"
  fi

  # Check for agents directory
  if [ -d "$INSTALL_PATH/agents" ]; then
    echo ""
    echo "🤖 Agents Provided:"
    ls "$INSTALL_PATH/agents" 2>/dev/null || echo "  (none)"
  fi
else
  echo ""
  echo "⚠️  Plugin directory not found: $INSTALL_PATH"
fi
