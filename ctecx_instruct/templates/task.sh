#!/usr/bin/env bash
# task.sh — ctecx_instruct executable part
# owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
# task_id: ctecx-<topic>-<seq>
# idempotent + safe-by-default. Destructive ops require RUN_DESTRUCTIVE=1.
set -euo pipefail

TASK_ID="${TASK_ID:-ctecx-<topic>-<seq>}"
WORKDIR="${WORKDIR:-.}"
RUN_DESTRUCTIVE="${RUN_DESTRUCTIVE:-0}"

log() { printf '[ctecx_instruct] %s\n' "$*"; }

setup() {
  log "setup: $TASK_ID"
  # Put install/prep steps here. E.g.:
  # python -m pip install --quiet -e ./python
}

build() {
  log "build: $TASK_ID"
  # Put build/compile steps here.
}

run() {
  log "run: $TASK_ID"
  # Put the main run steps here.
}

test() {
  log "test: $TASK_ID"
  # Put verification steps here. MUST exit non-zero on failure.
}

verify_manifest() {
  # sha256 manifest check against task.json (only if task.json present)
  if [ -f "task.json" ]; then
    python - <<'PY'
import hashlib, json, pathlib, sys
m = json.load(open("task.json", encoding="utf-8"))
ok = True
for f in m.get("manifest", []):
    p = pathlib.Path(f["path"])
    if not p.is_file():
        print("MISSING", f["path"]); ok = False; continue
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    if h != f["sha256"]:
        print("HASH MISMATCH", f["path"]); ok = False
sys.exit(0 if ok else 1)
PY
  fi
}

main() {
  setup
  build
  run
  test
  verify_manifest
  log "closed: $TASK_ID"
}

case "${1:-all}" in
  setup) setup ;;
  build) build ;;
  run) run ;;
  test) test ;;
  all) main ;;
  *) echo "usage: $0 [setup|build|run|test|all]"; exit 2 ;;
esac