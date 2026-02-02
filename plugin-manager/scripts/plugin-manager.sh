#!/bin/bash
# Unified plugin management tool

SCRIPTS_DIR="$HOME/.claude/skills/plugin-manager/scripts"

show_help() {
  cat <<EOF
🔧 Claude Code Plugin Manager
==============================

Usage: $0 <command> [options]

Commands:
  list                    List all installed plugins
  skills                  List all local skills
  info <plugin-name>      Show detailed info about a plugin
  update [options]        Update plugins (interactive selection)
  backup                  Backup plugin configuration
  check-updates           Check for available updates
  export                  Export plugin list to markdown
  help                    Show this help message

Update Options:
  update                  Interactive mode - select plugins to update
  update --all            Update all plugins with available updates
  update <plugin-name>    Update a specific plugin

Examples:
  $0 list
  $0 info oh-my-claudecode@omc
  $0 backup
  $0 check-updates

EOF
}

case "$1" in
  list)
    "$SCRIPTS_DIR/list-plugins.sh"
    ;;
  skills)
    "$SCRIPTS_DIR/list-skills.sh"
    ;;
  update)
    shift
    "$SCRIPTS_DIR/update-plugins.sh" "$@"
    ;;
  info)
    if [ -z "$2" ]; then
      echo "Error: Plugin name required"
      echo "Usage: $0 info <plugin-name>"
      exit 1
    fi
    "$SCRIPTS_DIR/plugin-info.sh" "$2"
    ;;
  backup)
    "$SCRIPTS_DIR/backup-plugins.sh"
    ;;
  check-updates)
    "$SCRIPTS_DIR/check-plugin-updates.sh"
    ;;
  export)
    echo "# Installed Claude Code Plugins"
    echo ""
    echo "Generated: $(date)"
    echo ""
    jq -r '.plugins | to_entries[] | "- **\(.key)** - v\(.value[0].version) (installed: \(.value[0].installedAt | split("T")[0]))"' \
      ~/.claude/plugins/installed_plugins.json | sort
    ;;
  help|--help|-h|"")
    show_help
    ;;
  *)
    echo "Error: Unknown command '$1'"
    echo ""
    show_help
    exit 1
    ;;
esac
