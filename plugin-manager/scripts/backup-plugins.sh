#!/bin/bash
# Backup plugin configuration

BACKUP_DIR="$HOME/.claude/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/plugins_backup_$TIMESTAMP.json"

mkdir -p "$BACKUP_DIR"

echo "📦 Backing up plugin configuration..."
cp ~/.claude/plugins/installed_plugins.json "$BACKUP_FILE"

echo "✅ Backup saved to: $BACKUP_FILE"
echo ""
echo "To restore: cp $BACKUP_FILE ~/.claude/plugins/installed_plugins.json"
