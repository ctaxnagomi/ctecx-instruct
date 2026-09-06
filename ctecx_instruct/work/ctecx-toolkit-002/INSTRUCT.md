<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-002`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Build the **CTECX ADE + IDE** on the CTECX Developer Toolkit delivery
(`ctecx-toolkit-001`): one shared language engine ("CTECX script", `.ctk`)
driving two surfaces — an IDE (incremental syntax, diagnostics, hover,
completion, JSON-lines language server + headless CLI) and an ADE (an
`observe → act → verify` agent harness with a tool allowlist, a human gate for
destructive steps, and every action persisted to an `agent_memory` SQLite
store using the `ctecx_instruct` task.sql schema).

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- Shell is win32/bash; everything must be stdlib Python 3.9+ (no external deps).
- Ownership banner on every file: `wan mohd azizi bin wan hosen, ctaxnagomi, est 2024`.
- CWD of the shell is the `kim-guesthouse` git workspace — use absolute paths.
- C: drive was at ~100% (shallow clones only); 2 GB now free — fine.
- The ADE db persists under a per-task sqlite file (`agent_memory_<task_id>.sqlite`
  by default) populated from the core/schema.sql layout.

## Work State

### Completed
- Monorepo scaffolded with logo (`assets/`), README, pyproject console scripts
  (`ctecx-ide`, `ctecx-ade`, `ctk`).
- **Engine** `core/ctk/`: lexer (with `#` comments, positions), parser (recursive
  descent, precedence, fn/if/else/while/let/print/return), tree-walking
  interpreter with lexical-closure frames, and a `disasm.py` emitting
  ctecx_instruct-style mnemonics (MOV/PUSH/CALL/CMP/JZ/RET/HLT).
- **IDE** `ide/`: `LanguageEngine` (analyze/hover/complete/evaluate/listing) +
  JSON-lines protocol server + `ide/cli.py` (analyze/listing/lsp).
- **ADE** `ade/`: `tools.py` allowlist (`read_file`, `list_files`, `run_test`,
  `write_file`) with `human-gate` (destructive tools need `RUN_DESTRUCTIVE=1`);
  `harness.py` Agent loop persisting observe/act/verify to `agent_memory`
  (core/memory.py, schema in core/schema.sql); `ade/harness.py` CLI
  (run/session/close).
- End-to-end verification `run_tests.py`: **20/20 checks pass** — language
  evaluation (`1+2*3=7`, `fib(10)=55`), division-by-zero + undefined-var
  errors, listing mnemonics, IDE diagnostics on broken + good files, LSP
  JSON-lines round-trip + completion, ADE run/destroy-gate/sqlite
  observe-act-verify persistence, task close.
- Live CLI demos verified: `ctk "1 + 2 * 3"` → 7; `ctk samples/fib.ctk` → 55;
  `ide analyze samples/{hello,broken}.ctk`; `ade run --tool run_test` → rc 0
  with audit rows; `ade session` replay shows roles observe/act/verify.
- **Distribution**: project-local venv (`python -m venv .venv`), editable install
  via `pip install -e .`; console scripts fixed to the setuptools convention
  (`main(argv=None)` — entry points are invoked with no args), so `ctk`,
  `ctecx-ide`, `ctecx-ade` `.exe` launchers run correctly **from any cwd** after
  editable install. Built wheel `dist/ctecx_ade_ide-0.1.0-py3-none-any.whl`
  (packages core/ide/ade, 3 console_scripts entries). `run_tests.py` still
  **20/20** after the signature fix.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. Scaffold `ctecx-ade-ide/` tree, logo, README.
2. Engine: lexer → parser → AST → interpreter + disassembler + REPL.
3. IDE: language server engine + protocol + CLI.
4. ADE: tools + gate + harness + sqlite persistence.
5. `run_tests.py` and CLI smoke checks until 20/20 pass.
6. Log this task as a `ctecx_instruct` pack.

## Deliverables

- `ctecx-ade-ide\` monorepo (core engine, ide, ade, samples, pyproject,
  run_tests) — all files ownership-bannered.
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-002.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `20/20 checks passed`.
- `python -m core.ctk.repl "1 + 2 * 3"` → `7`; `python -m core.ctk.repl samples/fib.ctk` → `55`.
- `python -m ide.cli analyze samples/hello.ctk` → `diagnostics: none`.
- `python -m ade.harness run --tool write_file ...` blocked without
  `RUN_DESTRUCTIVE=1`, allowed with it.
- Console scripts from an unrelated cwd (venv editable install): `ctk "1 + 2 * 3"`
  → `7`; `ctecx-ide analyze samples/hello.ctk` → rc 0; `ctecx-ade run ...` → rc 0,
  session replay → status `closed`, 3 memory rows; `write_file` → phase
  `blocked` without `RUN_DESTRUCTIVE=1`.
- Wheel `dist/ctecx_ade_ide-0.1.0-*.whl` contains `core`/`ide`/`ade` packages and
  entries `ctecx-ade`, `ctecx-ide`, `ctk`.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```