<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-005`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Connect the ADE (Agentic Development Environment, from `002`) to the dev
shell / web client (`003`, `004`): a thread-safe `AgentService` behind the
JSON-lines protocol (`ade_run`, `ade_status`, `ade_close`, `tools`) with a
**one-shot human gate** — a destructive tool call (e.g. `write_file`) never
executes until an approver repeats the exact tool+argv. Verified end-to-end
in a real browser: gated → approve → file written → memory trail replayed.

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- The dev shell is multi-threaded (`ThreadingTCPServer`);
  `sqlite3` (check_same_thread) forbids cross-thread connection reuse, and
  `Agent` keeps one connection per task. Each task's Agent is therefore pinned
  to **one dedicated `_Worker` thread** (never a `ThreadPoolExecutor`, whose
  worker thread identity was observed to change across submits).
- Gate rules: non-destructive → runs immediately (`approved:false`); destructive
  first call → `phase:"gated"`, nothing executes; `approve` with a different
  tool/argv → `phase:"forbidden"`; matching `approve` runs exactly once with
  `RUN_DESTRUCTIVE=1` injected into a copy of the env, then the flag is cleared
  (one-shot; the caller's real environment is never mutated).
- Console scripts are the venv `.exe` launchers (editable install) — source
  edits are picked up at runtime without reinstall since only
  `from ide.cli import main; main()` is baked in.
- Live UI checked with BrowserOS neo (agent browser); screenshots unreadable,
  so verification used DOM-text/`evaluate` assertions over the real HTTP proxy.
- The bash tool kills backgrounded children — demo server spawned detached
  (`CREATE_NEW_PROCESS_GROUP | DETACHED_PROCESS`) and torn down with
  `taskkill //T //F`.

## Work State

### Completed
- `ade/service.py`: `AgentService` (db_dir-per-task, per-task `_Worker` thread
  with a persistent loop + `_submit_wait`; `run`/`approve`/`status`/`close`/
  `shutdown`; `get_service` singleton; DESTRUCTIVE_TOOLS derived from the
  allowlist). Fixed along the way: non-reentrant lock deadlock (submit outside
  the guard), caller-thread Agent construction (executor-slot only), SQLite
  cross-thread reuse (per-agent dedicated thread), and interpreter hang
  (daemon worker threads).
- `ide/server.py` `handle_message`: new `ade_run` (params taskId/tool/argv/
  decision) and `ade_status`, plus `ade_close` and `tools`; `service=` injection
  for tests, `get_service()` default.
- `ide/index.html`: ADE panel — taskId field, tool select populated from the
  allowlist (destructive marked `(GATED)`), argv-as-JSON field, ADE run /
  Approve gate / Status buttons; gated/forbidden/ok rendered distinctly.
- `run_tests.py`: `test_ade_service` — non-destructive ok, gated doesn't
  execute, wrong-argv approve forbidden, matching approve writes, flag cleared,
  status/pending+memory, protocol paths with injected service, tools gate
  advertisement. **41/41 checks pass**.
- Live browser walk (BrowserOS neo, detached `ctecx-ide dev`): selected
  `write_file (GATED)`, argv `["web_demo.txt","gated-ok"]`; ADE run →
  `GATED — press the gate` and the file did NOT exist; Approve gate →
  `# write_file … wrote web_demo.txt`, the file contained `gated-ok`; Status →
  `exists:true, memory_count:3` (observe/act/verify), `pending:null`.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. Read `ade/tools.py` allowlist + gate; design the one-shot controller.
2. Write `ade/service.py` with per-task dedicated worker threads.
3. Add `ade_run`/`ade_status`/`ade_close`/`tools` to `handle_message`
   (injectable `service=`).
4. Add the ADE panel to `ide/index.html`.
5. Add `test_ade_service`; iterate to 41/41 (lock, thread, exit hangs).
6. Detached live run + BrowserOS neo gate-flow verification.
7. Log task as a `ctecx_instruct` pack; commit the repo.

## Deliverables

- `ade/service.py`, `ade/harness.py`, `ide/server.py`, `ide/index.html`,
  `run_tests.py` (in `ctecx-ade-ide`).
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-005.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `41/41 checks passed`.
- Detached `ctecx-ide dev` on :8086 → `/status` `{"ok":true,"engine":"127.0.0.1:9903"}`.
- Browser gate flow: gated (file absent) → approve (file `gated-ok`) → status
  `memory_count:3, pending:null`; `RUN_DESTRUCTIVE` cleared after the call.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```