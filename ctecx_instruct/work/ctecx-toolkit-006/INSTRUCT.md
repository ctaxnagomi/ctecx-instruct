<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-006`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Extend the ADE (from `005`) with **plan mode — the task loop**:
`ade_run` now accepts a whole `plan` (an array of `{tool, argv, expect?}`
steps), the harness drives observe → act → verify over it, pauses before
every destructive step for the one-shot human gate, halts with
`phase:"failed"` on an `expect` mismatch, and returns `phase:"ret"` when the
whole plan verifies. `ade_abort` clears a paused plan without executing the
pending step. Verified end-to-end in a real browser: plan gated at the
destructive step → one-click approve → resume → RET; failed plan halts;
paused → abort clears everything.

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- `AgentService` state now holds, per task, an optional in-flight plan:
  `self._plans[task_id] = (steps, cursor)` and an optional pending
  approval `self._pending[task_id] = (tool, argv_tuple)` — both set/cleared
  **under `self._lock`** before any submit, so the plan worker thread
  (`_exec_plan` / `_resume_plan`) never races the gate.
- Plan flows:
  - fresh `run_plan(task_id, steps, decision)` — stored plan submitted to the
    worker; a destructive step that is not yet approved pauses the loop at its
    index (nothing executes) and returns `phase:"paused", step, steps_total,
    tool, argv`.
  - `run(task_id, decision="approve")` with **no tool/argv** now approves
    "whatever is pending" (single step or paused plan); approval is decided
    *before* tool-allowlist validation, since the tool may be empty.
    Explicit tool+argv approve must match `pending == (tool, argv)` exactly,
    else `phase:"forbidden"`.
  - resume replays the plan from the paused cursor with the approved step
    executed once (`RUN_DESTRUCTIVE=1` injected into a copy of the env).
  - `_normalize_steps` rejects unknown tools, non-list argv, and empty plans
    (`phase:"rejected"`); `max_iterations` is bumped to the plan length so a
    long plan is never killed mid-loop.
  - expect verification: step passes iff `ok` and when `expect` is set the
    joined output contains it; mismatch → `phase:"failed"` with the step
    index, `output_tail`, and later steps never run.
- UI: `ide/index.html` gained a plan-input field (JSON), **ADE plan** and
  **Abort plan** buttons; **Approve gate** is now a true one-click approve
  that sends only `{taskId, decision:"approve"}` (no tool/argv), matching the
  service's "approve whatever is pending" semantics.
- The dev shell proxies `/rpc`; the whole demo ran over the real HTTP proxy
  with BrowserOS neo. bash kills backgrounded children → detached spawn
  (`CREATE_NEW_PROCESS_GROUP | DETACHED_PROCESS`), `taskkill //T //F` to stop.
- Repo pushed to GitHub: `ctaxnagomi/ctecx-ade-ide` (public, main).

## Work State

### Completed
- `ade/service.py`: `run_plan` / `_exec_plan` / `_normalize_steps` /
  `_approved_step` / `_resume_plan` / `abort`, `_plans` state, plan info in
  `status`, and a **reordered `run()`**: approve handling now precedes tool
  validation so a tool-less approve can gate the pending step (single-step or
  paused plan); the single-step paths keep their previous semantics.
- `ide/server.py` `handle_message`: `ade_run` dispatches to
  `service.run_plan` when `params["plan"]` is a list (else `service.run`);
  new `ade_abort` → `service.abort`.
- `ide/index.html`: plan JSON input + ADE plan / Abort plan buttons; approve
  button simplified to a one-click gate.
- `ide/cli.py`: `dev`/`web` reachable and serving the updated panel
  (console-script `.exe` picks up source edits at runtime — no reinstall).
- `run_tests.py`: `test_ade_plan` — non-destructive plan RETs with checks;
  mid-plan destructive pauses without executing; wrong-argv approve forbidden
  while plan stays paused; UI-style tool-less approve resumes → RET + file
  written; expect-mismatch → `failed` at step 0 (later step not run); abort
  clears a paused plan so a fresh one starts; protocol routing for
  plan/approve/status with injected service. **59/59 checks pass**.
- README: plan-mode snippet, `ade_abort`, updated ADE panel walkthrough.
- Live browser walk (BrowserOS neo, detached `ctecx-ide dev` :8087):
  plan `[run_test print(42) expect 42 → write_file plan_demo.txt → read_file
  expect plan-demo-ok]` → `PLAN paused at 1/3` at the `write_file` step (file
  absent on disk) → Approve gate → `PLAN RET — 3 steps ok`, file contains
  `plan-demo-ok`, `ade_status` shows `plan:null, pending:null`; failing plan
  (expect 43) → `PLAN FAILED at step 0`, later step never ran; destructive-
  first plan → `PLAN paused at 0/2` → Abort → `plan:null, pending:null`, file
  never written; `ade_abort` on a finished task is a no-op.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. Rewrite `ade/service.py`: `run_plan`, plan worker, resume, abort; reorder
   `run()` approve before tool validation.
2. Wire `plan` dispatch + `ade_abort` into `handle_message`.
3. Add plan UI (plan field, ADE plan / Abort buttons, one-click gate) to
   `ide/index.html`.
4. Add `test_ade_plan`; iterate to 59/59.
5. Detached live run + BrowserOS neo plan gate/resume/ret/fail/abort walk.
6. Update README; log the task as a `ctecx_instruct` pack; commit the repo.

## Deliverables

- `ade/service.py`, `ide/server.py`, `ide/index.html`, `run_tests.py`,
  `README.md` (in `ctecx-ade-ide`).
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-006.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `59/59 checks passed`.
- Detached `ctecx-ide dev` on :8087 → `/status` `{"ok":true,"engine":"127.0.0.1:9904"}`.
- Browser: plan paused at destructive step (1/3, file absent) → approve →
  `PLAN RET — 3 steps ok`, file `plan-demo-ok`, status `plan:null,pending:null`;
  failed plan → `PLAN FAILED at step 0`; paused → abort → `plan:null`,
  file never written.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```