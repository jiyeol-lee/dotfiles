#!/usr/bin/env bash
set -euo pipefail

DB_DIR="${HOME}/.local/share/conversation-memory"
DB="${DB_DIR}/memory.db"

usage() {
  cat <<'EOF'
Usage:
  memory.sh setup
  memory.sh directory
  memory.sh read
  memory.sh write <memory> --category <category>
  memory.sh archive <id>

Commands:
  setup      Create the SQLite database schema and indexes.
  directory  Print the detected project directory.
  read       Read active memories for the detected project directory only.
  write      Insert a memory for the detected project directory.
  archive    Archive a memory by id for the detected project directory.

Categories:
  preference | convention | note

Project directory detection:
  If .git exists in the current directory, use:
    git worktree list --porcelain | awk 'NR==1 {print $2}'
  Otherwise, use pwd.

Database:
  ~/.local/share/conversation-memory/memory.db
EOF
}

require_sqlite() {
  if ! command -v sqlite3 >/dev/null 2>&1; then
    printf 'Error: sqlite3 is required but was not found in PATH.\n' >&2
    exit 1
  fi
}

detect_directory() {
  if [ -e .git ]; then
    git worktree list --porcelain | awk 'NR==1 {print $2}'
  else
    pwd
  fi
}

sql_literal() {
  local value
  value=${1//\'/\'\'}
  printf "'%s'" "$value"
}

setup_db() {
  require_sqlite
  mkdir -p "$DB_DIR"

  sqlite3 "$DB" <<'SQL'
CREATE TABLE IF NOT EXISTS memories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  directory TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('preference', 'convention', 'note')),
  memory TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  archived_at TEXT
);
SQL

  sqlite3 "$DB" <<'SQL'
CREATE INDEX IF NOT EXISTS idx_memories_directory ON memories(directory);
CREATE INDEX IF NOT EXISTS idx_memories_category ON memories(category);
CREATE INDEX IF NOT EXISTS idx_memories_archived_at ON memories(archived_at);
SQL
}

validate_category() {
  case "$1" in
  preference | convention | note) ;;
  *)
    printf 'Error: invalid category "%s". Allowed categories: preference, convention, note.\n\n' "$1" >&2
    usage >&2
    exit 2
    ;;
  esac
}

read_memories() {
  setup_db
  local dir
  dir="$(detect_directory)"
  sqlite3 "$DB" -header -column <<SQL
SELECT id, directory, category, memory, updated_at
FROM memories
WHERE directory = $(sql_literal "$dir")
  AND archived_at IS NULL
ORDER BY updated_at DESC;
SQL
}

archive_memory() {
  if [ "$#" -ne 1 ] || [ -z "${1:-}" ]; then
    printf 'Error: archive requires a memory id.\n\n' >&2
    usage >&2
    exit 2
  fi

  local id dir changes
  id="$1"
  case "$id" in
  '' | 0 | *[!0-9]*)
    printf 'Error: archive id must be a positive integer.\n\n' >&2
    usage >&2
    exit 2
    ;;
  esac

  setup_db
  dir="$(detect_directory)"
  changes="$(
    sqlite3 "$DB" <<SQL
UPDATE memories
SET archived_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $id
  AND directory = $(sql_literal "$dir")
  AND archived_at IS NULL;
SELECT changes();
SQL
  )"

  if [ "$changes" -eq 0 ]; then
    printf 'Error: active memory id %s was not found for this project directory.\n' "$id" >&2
    exit 1
  fi
}

write_memory() {
  if [ "$#" -lt 3 ]; then
    usage >&2
    exit 2
  fi

  local category memory dir
  memory="$1"
  category=""
  shift

  while [ "$#" -gt 0 ]; do
    case "$1" in
    --category)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        printf 'Error: --category requires a value.\n\n' >&2
        usage >&2
        exit 2
      fi
      category="$2"
      shift 2
      ;;
    *)
      printf 'Error: unknown write option "%s".\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    esac
  done

  if [ -z "$memory" ]; then
    printf 'Error: memory text is required.\n\n' >&2
    usage >&2
    exit 2
  fi

  if [ -z "$category" ]; then
    printf 'Error: --category is required.\n\n' >&2
    usage >&2
    exit 2
  fi

  validate_category "$category"
  setup_db
  dir="$(detect_directory)"

  sqlite3 "$DB" <<SQL
INSERT INTO memories (directory, category, memory, created_at, updated_at)
VALUES ($(sql_literal "$dir"), $(sql_literal "$category"), $(sql_literal "$memory"), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
SQL
}

main() {
  case "${1:-}" in
  setup)
    setup_db
    ;;
  directory)
    detect_directory
    ;;
  read)
    read_memories
    ;;
  write)
    shift
    write_memory "$@"
    ;;
  archive)
    shift
    archive_memory "$@"
    ;;
  -h | --help | help | "")
    usage
    ;;
  *)
    printf 'Error: unknown command "%s".\n\n' "$1" >&2
    usage >&2
    exit 2
    ;;
  esac
}

main "$@"
