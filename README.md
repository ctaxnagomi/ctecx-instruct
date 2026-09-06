<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# ctecx_formatter

The CTECX formatting / packaging layer. It sits at the same level as `ctecx_build`
(build conventions) and defines the structured artifact format used to log and drive
every CTECX task from an IDE or ADE (agentic development environment).

Current format: **`ctecx_instruct`** — a five-part, zip-able instruction pack.

## Layout

```
ctecx_formatter/
├── README.md
└── ctecx_instruct/
    ├── templates/   # canonical skeleton for each of the 5 parts
    └── packs/       # one zip per task: ctecx_instruct_<task_id>.zip
```

## ctecx_instruct — format spec

One pack per task. The pack is the source of truth an agent (or human) follows to
execute, verify and close a task. Every part carries the ownership banner:

> **wan mohd azizi bin wan hosen, ctaxnagomi, est 2024**

| Part            | Kind      | Purpose                                                            |
|-----------------|-----------|--------------------------------------------------------------------|
| `INSTRUCT.md`   | document  | Task log: identity, objective, context, constraints, steps, deliverables, verification. |
| `task.sh`       | executable| Reproducible setup/build/run/test script. Idempotent, safe-by-default. |
| `task.sql`      | schema    | `agent_memory` persistence + `task_meta` audit, so the task state lives in the DB an ADE/IDE attaches to. |
| `task.json`     | metadata  | Machine-readable task_id, owner, dates, params, file manifest (sha256). |
| `task.assembly` | plan      | The build written as a program listing: labelled segments, step "opcodes", register-style state tracking, verification mnemonics. |

### Conventions
- `task_id` shape: `ctecx-<topic>-<seq>` (e.g. `ctecx-toolkit-001`).
- `INSTRUCT.md` MUST contain the Objective / Important Details / Work State /
  Next Move blocks so any follow-up session can resume purely from the pack.
- `task.sh` MUST start with `set -euo pipefail`, must be idempotent, must not
  contain destructive commands by default (guard with `RUN_DESTRUCTIVE=1`).
- `task.sql` MUST create `agent_memory` (msg_id, sender, role, payload, ts,
  embedding) and `task_meta` (task_id, owner, status, started_at, closed_at).
- `task.json` MUST have `format_version: "ctecx_instruct@1"` and MUST ship a
  `manifest` with sha256 for the four content parts (INSTRUCT.md, task.sh,
  task.sql, task.assembly). `task.json` is excluded from its own manifest — a
  file cannot hash itself (its integrity is covered by the zip).
- `task.assembly` MUST mirror the INSTRUCT steps as labelled segments with
  opcode-style mnemonics (`MOV` move/assign, `CALL` invoke, `CMP` check,
  `JZ` decision, `RET` finish).

### Packaging
- Zip exactly the five files at the zip root (no subfolder).
- Name: `ctecx_instruct_<task_id>.zip`.
- Store under `ctecx_instruct/packs/`.
- Ownership lives inside each file; the zip is just the transport.