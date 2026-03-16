#!/usr/bin/env bash
# overnight.sh — Run Claude Code skills autonomously without manual intervention
#
# Usage:
#   ./scripts/overnight.sh                          # run all tasks in tasks.txt
#   ./scripts/overnight.sh --task "implement X"     # run a single task
#   ./scripts/overnight.sh --file tasks.txt         # run tasks from file
#   ./scripts/overnight.sh --dry-run                # show what would run
#
# Prerequisites:
#   - Claude Code CLI installed and authenticated
#   - ANTHROPIC_API_KEY set in environment
#
# Schedule with cron:
#   0 22 * * 1-5 cd /path/to/project && ./scripts/overnight.sh >> logs/cron.log 2>&1

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
LOG_DIR="${PROJECT_DIR}/logs/overnight"
TASKS_FILE="${PROJECT_DIR}/scripts/tasks.txt"
MAX_TURNS="${MAX_TURNS:-200}"
MAX_BUDGET="${MAX_BUDGET:-5.00}"        # USD per task — safety net
MODEL="${MODEL:-}"                       # empty = use default
TIMEOUT="${TIMEOUT:-3600}"               # seconds per task (1 hour default)
DRY_RUN=false
SINGLE_TASK=""

# Tools to allow without prompting
ALLOWED_TOOLS="Read,Write,Edit,Bash,Glob,Grep,Agent,WebSearch,WebFetch"

# ── Parse Arguments ────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case $1 in
    --task)      SINGLE_TASK="$2"; shift 2 ;;
    --file)      TASKS_FILE="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --budget)    MAX_BUDGET="$2"; shift 2 ;;
    --timeout)   TIMEOUT="$2"; shift 2 ;;
    --max-turns) MAX_TURNS="$2"; shift 2 ;;
    --model)     MODEL="$2"; shift 2 ;;
    *)           echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Setup ──────────────────────────────────────────────────────────────────────

mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SUMMARY_LOG="$LOG_DIR/summary-$TIMESTAMP.log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$SUMMARY_LOG"; }

log "═══════════════════════════════════════════════"
log "  OVERNIGHT RUN — $TIMESTAMP"
log "  Project: $PROJECT_DIR"
log "  Budget:  \$$MAX_BUDGET per task"
log "  Timeout: ${TIMEOUT}s per task"
log "═══════════════════════════════════════════════"

# ── Build Task List ────────────────────────────────────────────────────────────

TASKS=()

if [[ -n "$SINGLE_TASK" ]]; then
  TASKS+=("$SINGLE_TASK")
elif [[ -f "$TASKS_FILE" ]]; then
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    TASKS+=("$line")
  done < "$TASKS_FILE"
else
  log "❌ No tasks found. Create scripts/tasks.txt or use --task"
  exit 1
fi

log "Tasks queued: ${#TASKS[@]}"
echo ""

if $DRY_RUN; then
  for i in "${!TASKS[@]}"; do
    log "  [$((i+1))] ${TASKS[$i]}"
  done
  log ""
  log "Dry run — no tasks executed."
  exit 0
fi

# ── Git Safety — Create checkpoint ─────────────────────────────────────────────

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  CHECKPOINT="pre-overnight-$TIMESTAMP"
  git tag "$CHECKPOINT" 2>/dev/null || true
  log "Git checkpoint: $CHECKPOINT"
  log "  Rollback with: git reset --hard $CHECKPOINT"
fi

# ── Execute Tasks ──────────────────────────────────────────────────────────────

PASSED=0
FAILED=0
SKIPPED=0

for i in "${!TASKS[@]}"; do
  TASK="${TASKS[$i]}"
  TASK_NUM=$((i + 1))
  TASK_LOG="$LOG_DIR/task-${TASK_NUM}-$TIMESTAMP.log"

  log ""
  log "━━━ TASK $TASK_NUM/${#TASKS[@]} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Prompt: $TASK"
  log "  Log:    $TASK_LOG"

  # Build claude command
  CMD=(claude -p "$TASK"
    --allowedTools "$ALLOWED_TOOLS"
    --max-turns "$MAX_TURNS"
    --output-format json
  )

  # Add model if specified
  [[ -n "$MODEL" ]] && CMD+=(--model "$MODEL")

  # Execute with timeout
  START_TIME=$(date +%s)

  if timeout "$TIMEOUT" "${CMD[@]}" > "$TASK_LOG" 2>&1; then
    DURATION=$(( $(date +%s) - START_TIME ))
    log "  ✅ PASSED (${DURATION}s)"
    PASSED=$((PASSED + 1))

    # Extract cost if available in JSON output
    COST=$(tail -1 "$TASK_LOG" | jq -r '.usage.cost // "unknown"' 2>/dev/null || echo "unknown")
    [[ "$COST" != "unknown" ]] && log "  Cost: \$$COST"
  else
    EXIT_CODE=$?
    DURATION=$(( $(date +%s) - START_TIME ))

    if [[ $EXIT_CODE -eq 124 ]]; then
      log "  ⏰ TIMEOUT after ${TIMEOUT}s"
      SKIPPED=$((SKIPPED + 1))
    else
      log "  ❌ FAILED (exit $EXIT_CODE, ${DURATION}s)"
      FAILED=$((FAILED + 1))
    fi

    # Extract last error from log
    LAST_ERROR=$(tail -5 "$TASK_LOG" 2>/dev/null | head -3)
    [[ -n "$LAST_ERROR" ]] && log "  Error: $LAST_ERROR"
  fi
done

# ── Summary ────────────────────────────────────────────────────────────────────

log ""
log "═══════════════════════════════════════════════"
log "  OVERNIGHT RUN COMPLETE"
log "  Total:   ${#TASKS[@]}"
log "  Passed:  $PASSED ✅"
log "  Failed:  $FAILED ❌"
log "  Timeout: $SKIPPED ⏰"
log "  Logs:    $LOG_DIR/"
log "═══════════════════════════════════════════════"

# Exit with failure if any task failed
[[ $FAILED -gt 0 ]] && exit 1
exit 0
