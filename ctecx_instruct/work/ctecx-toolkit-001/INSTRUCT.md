<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-001`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Build the **CTECX Developer Toolkit** — the unified reference implementation for
IDE components, ADE (Agentic Development Environment) harnesses, and a
scripting/language workbench (assembly → custom language runtime) — and log the
task as a `ctecx_instruct` pack.

## Important Details

- Toolkit target dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-developerToolKit\`
  (user created the folder; note the user typo `ctec-developerToolKit` — actual
  name is `ctecx-developerToolKit`).
- Ownership banner on every file: `wan mohd azizi bin wan hosen, ctaxnagomi, est 2024`.
- Logo: `ctecx_official_logo_01_badge.png` on README (also committed in the CTECX
  GitHub repo at `assets/`).
- `ctecx_instruct` format created under `ctecx_formatter` at the same level as
  `ctecx_build`. Neither existed on GitHub (full ctaxnagomi repo list) or locally;
  both created fresh under `ctecx-developer\`.
- CWD of the shell is the `kim-guesthouse` git workspace — use absolute paths.
- Shell is win32/bash; python CLI must stay stdlib-only (>=3.9).

## Work State

### Completed
- Research grounded (websearch 2026): x86-64 assembly (registers, opcodes,
  System V ABI, JIT/mmap PROT_EXEC); language pipeline (lexer→parser→AST→bytecode
  VM, transpile); IDE architecture (Tree-sitter ~1ms incremental + LSP semantic
  hybrid, Zed model); Electron vs Tauri 2.0 (Tauri 2.0 stable, ~96% smaller
  bundles, low memory; Electron on VS Code/Slack).
- `ctecx_formatter` + `ctecx_instruct` templates written and verified.
- Toolkit built and smoke-tested:
  - `python/` CLI (`ctecx-tk init-ide|init-ade|init-language|instruct`) — stdlib.
  - Language scaffold bytecode VM computes `1 + 2 * 3 = 7.0`, `2+2 = 4.0`.
  - IDE scaffold parses and reports tokens/diags.
  - ADE scaffold runs observe→act→verify; `human-gate.sh` blocks destructive
    steps without `RUN_DESTRUCTIVE=1`.
  - samples: `hello_x64.asm`, `tokenizer.rs`, `electron.main.ts`,
    `tauri/src-tauri/{Cargo.toml,tauri.conf.json}`, `ade_agent_harness.py`.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None. (GitHub README update is a separate task: ctecx-toolkit-002.)

## Execution Steps

1. Verify `ctecx-build`/`ctecx_build` existence (GitHub + local). → absent → created both siblings.
2. Create `ctecx_formatter\ctecx_instruct` format (5 templates + spec README).
3. Scaffold toolkit tree, docs, python CLI, samples; add ownership banners + logo.
4. Smoke-test CLI scaffolds (py_compile + run generated VM/IDE/ADE/gate).
5. Write this task log; generate + zip the pack via `ctecx-tk instruct`.

## Deliverables

- `ctecx-developer\ctecx_build\` (sibling marker README)
- `ctecx-developer\ctecx_formatter\README.md` + `ctecx_instruct\templates\*`
- `ctecx-developer\ctecx-developerToolKit\` — README (logo), `docs\` (4 research
  docs), `python\` (ctecx-tk CLI), `samples\` (5 stacks), ownership everywhere
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-001.zip` (5 parts at root)

## Verification

- `python -m py_compile src/ctecx_tk/*.py` passes.
- Scaffold language: `python -m src.main "1 + 2 * 3"` → `7.0`.
- `human-gate.sh` exits 1 without `RUN_DESTRUCTIVE=1`.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```