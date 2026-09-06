<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-004`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Give the CTECX IDE delivery (`ctecx-toolkit-002`, dev shell `003`) a real
front end: a **zero-dependency web client** (stdlib only) that proxies to the
JSON-lines TCP dev-shell engine, plus a one-command `ctecx-ide dev` that runs
engine + webapp together. Verified end-to-end in a real browser (BrowserOS neo):
type CTECX script, Run / Analyze / Listing over HTTP → engine.

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- Console scripts are the venv `.exe` launchers (editable install from 002;
  they snapshot at install time, so reinstall after entry-point changes).
- BrowserOS neo is the user's agent browser — used for the live UI check
  (its screenshots can't be read by this model, so verification used DOM text
  assertions + `evaluate`).
- The bash tool kills backgrounded children, so the live demo server was
  spawned detached via `subprocess` (`CREATE_NEW_PROCESS_GROUP |
  DETACHED_PROCESS`) and torn down with `taskkill //T //F` + /status probe.
- Flag convention on the CLI: `--host/--port` (engine), `--http-port` (web),
  `--engine-host/--engine-port` (override target engine for `web`).

## Work State

### Completed
- `ide/webapp.py`: `DevShellProxy` (per-request JSON-lines socket to the
  engine) + `ThreadingHTTPServer` handler (`GET /` index, `GET /status` engine
  ping, `POST /rpc` proxy; errors 502 with `{"id", "error"}`); `make_server`,
  `serve`, and `serve_dev` (engine + web in one process via threads).
- `ide/index.html`: dark CTECX IDE UI — .ctk editor, Run / Analyze / Listing /
  Hover / Complete buttons, output panel, live engine status dot (5 s poll),
  Ctrl+Enter run, Ctrl+Space complete, caret→line/col for hover.
- `ide/cli.py`: `web` and `dev` subcommands; `_parse_host_port` now accepts
  `--http-port` or `--port`; usage updated.
- **Bug fixed**: `_collect_symbols` double-wrapped a fn body in `Block` (it was
  already a `Block`) → `'Block' object is not iterable` on analyze of any
  program containing a function; now `walk(node.body)`.
- `run_tests.py`: `test_webapp` (ephemeral engine + web, urllib): index served,
  status online, `evaluate → ["42"]` via proxy, diagnostics > 0 for bad code,
  completion `print`, fn-symbol collection. **29/29 checks pass**.
- Live subprocess driver (`ctecx-ide dev`): web listening, index bytes 5587,
  status `{ok:true, engine:127.0.0.1:9902}`, evaluate `['42']`, analyze
  `fns: ['add']`.
- Real-browser check (BrowserOS neo, detached `ctecx-ide dev` on :8085):
  Run `fib(10)` → `out=[55]`; Analyze → `no diagnostics / vars: r / fns: fib`;
  Listing → 4 SEGMENTs, `HLT` present, `CALL fib` present; deliberate bad input
  surfaced `unexpected character '"' (line 7, col 7)` from the engine.

### Active
- Version control: `git init` + initial commit for `ctecx-ade-ide`.
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. `ide/webapp.py`: proxy + HTTP server + `serve_dev` (single-process mode).
2. `ide/index.html`: editor UI with Run/Analyze/Listing/Hover/Complete + status.
3. Wire `web`/`dev` into `ide/cli.py`; fix `--http-port` parsing.
4. Fix `_collect_symbols` `Block` bug; add `test_webapp`; 29/29.
5. Detached live run + BrowserOS neo UI verification (DOM assertions).
6. `git init` + initial commit; log task as a `ctecx_instruct` pack.

## Deliverables

- Zero-dependency web client + `ctecx-ide dev` one-command mode (in `ctecx-ade-ide`).
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-004.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `29/29 checks passed`.
- `ctecx-ide dev --http-port 8085 --engine-port 9902` → status
  `{"ok": true, "engine": "127.0.0.1:9902"}`.
- Browser (real): Run → `55`; Analyze → `no diagnostics / vars: r / fns: fib`;
  Listing → 4 segments + `HLT` + `CALL fib`; bad input → engine lex error text.
- Git: initial commit contains only source (venv/dist/sqlite ignored per `.gitignore`).
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```