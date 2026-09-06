<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-003`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Add a **networked dev shell** to the CTECX IDE delivery (`ctecx-toolkit-002`): a
JSON-lines TCP language server (`ctecx-ide serve`) plus a client
(`ctecx-ide send`) so any GUI/front end can talk to the CTECX script language
server over a real socket — and fix the `evaluate` bug it flushed out.
Also add project hygiene (`.gitignore`) for the `ctecx-ade-ide` tree.

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- Console scripts live in the project-local venv (editable install from 002):
  `C:\...\ctecx-ade-ide\.venv\Scripts\{ctecx-ide,ctecx-ade,ctk}.exe`.
- The opencode shell tool kills backgrounded children, so OS-level `&` server
  demos are unreliable here — the live check spawns `serve` + `send` as
  subprocesses from a single Python driver (`Temp\opencode\ctecx_devshell_check.py`).
- Protocol is unchanged from 002 (JSON-lines); socket framing is one JSON object
  per line, request/response matched by `id`.
- `serve --port 0` binds an ephemeral port for tests; ThreadingTCPServer +
  daemon threads, reuse-address.

## Work State

### Completed
- `ide/server.py`: `make_server(host, port)` + `serve(host, port)` built on
  `socketserver.ThreadingTCPServer` (`_LanguageServerHandler` reads JSON-lines,
  replies with `handle_message`); port 0 = ephemeral; Ctrl-C exits cleanly.
- `ide/cli.py`: `serve [--host HOST --port PORT]` and `send [--host --port]`
  subcommands (`send` streams stdin → socket → stdout); usage docstring updated
  (analyze/listing/serve/send/lsp).
- **Bug fixed**: `LanguageEngine.evaluate` called `interp.run(Block(program.body))`
  but `run` expects the `Program` — surfaced only via the socket
  (`'Block' object has no attribute 'body'`). Now `interp.run(program)`.
- `run_tests.py`: added `test_ide_socket` (in-process ThreadingTCPServer on
  ephemeral port; raw socket analyze/complete/evaluate round-trips, one added
  for evaluate). **23/23 checks pass**.
- `.gitignore` added (venv, dist, wheels, __pycache__, egg-info, sqlite db, IDE dirs).
- Live dev-shell verified: `ctecx-ide serve --port 9911` + `ctecx-ide send`:
  analyze → `diagnostics: []`, 9 tokens; evaluate → `['56']`; listing → SEGMENT
  line returned over the wire; client exit 0.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. Add TCP transport (`make_server`/`serve`) + handler to `ide/server.py`.
2. Wire `serve` and `send` into `ide/cli.py`.
3. Socket round-trip tests in `run_tests.py` (ephemeral port, in-process thread).
4. Fix `evaluate` Program/Block bug caught by the socket path.
5. `run_tests.py` → 23/23; live subprocess-based serve/send transcript.
6. Hygiene `.gitignore`; log task as a `ctecx_instruct` pack.

## Deliverables

- TCP JSON-lines language server + client subcommands (in `ctecx-ade-ide`).
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-003.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `23/23 checks passed` (socket section: analyze,
  completion, evaluate round-trips).
- Live (single Python driver spawning the real exes):
  - `server listening: True`
  - `analyze -> diagnostics: [] | tokens: 9`
  - `evaluate -> output: ['56']`
  - `listing -> '; ---------------- SEGMENT .stmt0 (line 1) ----------------'`
- `ctecx-ide serve` binds and serves; `ctecx-ide send` round-trips and exits 0.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```