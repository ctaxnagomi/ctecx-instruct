<!-- owner: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024 -->

# CTECX Task Log — INSTRUCT

- **task_id**: `ctecx-toolkit-007`
- **owner**: wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
- **created**: `2026-09-06`
- **status**: `closed`
- **format_version**: `ctecx_instruct@1`

## Objective

Ship **language v-next** for CTECX script: real **strings**, **booleans**,
and **lists** in the engine, parser, disassembler, IDE, and REPL. Scope
(user-selected): string literals with escapes, `true`/`false` + `and`/`or`/
`not`, list literals `[a, b]` with indexing, and core builtins (`len`, `push`,
`range`, `join`, `split`, `str`, `num`). Comparisons now produce booleans;
truthiness is Python-like (`0`, `""`, `[]`, `false` falsy). Verified
end-to-end in a real browser via the IDE dev shell.

## Important Details

- Project dir: `C:\Users\wanmo\DeckerGUI\ctecx-developer\ctecx-ade-ide\`.
- The engine is stdlib-only; value model became heterogeneous: number
  (`float`), **str**, **bool**, **list**, `CtkFunction`.
- Lexer: new token kind `'str'` (raw source incl. quotes kept in
  `Token.text` so IDE columns/lines stay faithful; the parser decodes via
  `use.unescape`, registered as `unescape`). New keywords `true false and or
  not`; added `[` `]` to `SINGLE_OPS`. Escaped quotes `\"` are honoured while
  scanning; raw newlines inside a string are an error (single-line literals).
- Parser grammar gained `or/and` above `compare`, `not` in `unary`, and a
  `postfix` level (`primary ('[' expr ']')*`, also after a call result) so
  `xs[i]`, `g[i][j]`, and `fn(...)[0]` parse.
- Interpreter: comparisons return `true/false` (was 1.0/0.0); `and`/`or`
  short-circuit; `not` negates truthiness; `Index` bounds-checks with negative
  indexing support; `+` concatenates strings only and mixes are rejected
  (coerce with `str(x)`); unary `-` requires a number.
- Builtins are native `CtkFunction`s (`native`/`arity` slots checked in
  `_call`) so `len`/`range`/`push`/etc. take their real arg counts.
- `fmt` renders bools as `true/false`, strings as-is, lists as `[a, b, c]`,
  and builtins as `<builtin name>`.
- `run_tests.py` grew `test_language_vnext` (26 checks) + a `_raises` helper;
  **83/83** pass after also fixing one fixture ("completion offers true/false"
  queried two prefixes, `f`/`t`).
- Live browser walk (BrowserOS neo, detached `ctecx-ide dev` :8088): editor
  run of lists/bools/string code printed `[2, 3, 5, 7, 11]`, `2`, `5`,
  pushed list, `a / b / c`, `true`, `false` (short-circuit), `false` (`not
  true`); Analyze → no diagnostics + `xs` symbol; Listing → `PACK 3`,
  `IDX`, `"hi" ; string literal`, `true ; bool literal`.
- No packaging changes (new nodes live inside the existing `core.ctk`
  package); console scripts pick source edits up at runtime.

## Work State

### Completed
- `core/ctk/lexer.py`: `str` tokens with escaped-quote scanning, `[` `]`,
  `true/false/and/or/not` keywords, `unescape()` escape decoder
  (`\n \t \r \" \\ \0`).
- `core/ctk/ast.py`: `Str`, `Bool`, `ListExpr`, `Index` node types.
- `core/ctk/parser.py`: literals + list literals, `or`/`and`/`not` grammar
  levels, postfix indexing (`parse_postfix`, also after call results).
- `core/ctk/interp.py`: heterogeneous value model, truthiness, short-circuit
  logic, `Index` with bounds + negative indexing, string/list concat rules,
  native builtins `len range str num push join split`, `fmt` for all kinds.
- `core/ctk/disasm.py`: `PUSH "…" ; string literal`, `PUSH true/false`,
  `PACK n ; build list`, `IDX ; list[index]`, `NEG not`.
- `ide/server.py`: hover covers `str` tokens; completion offers the new
  keywords automatically (drawn from `KEYWORDS`).
- `samples/strings.ctk` + `samples/lists.ctk` (documented in README).
- `run_tests.py`: `test_language_vnext` — string concat/escapes/str(),
  bool output + short-circuit, truthiness control flow, list literal/index/
  negative/nested/bounds/non-list errors, push/range/len/join/split/num,
  mixed-`+` rejection, listing mnemonics, IDE token kind + completion.
  **83/83 checks pass**.
- README: new "Language" section + samples in Quick start and the layout tree.

### Active
- This task log pack is being generated and zipped.

### Blocked
- None.

## Execution Steps

1. Extend the lexer (str tokens, `[ ]`, new keywords, escape decoder).
2. Add AST nodes; wire parser grammar levels + postfix indexing.
3. Extend the interpreter (values, truthiness, logic, builtins, `fmt`).
4. Extend the disassembler; add hover/completion support in the IDE server.
5. New samples; `test_language_vnext`; iterate to **83/83**.
6. Detached live run + BrowserOS neo editor/analyze/listing verification.
7. Update README; log the task as a `ctecx_instruct` pack; commit the repo.

## Deliverables

- `core/ctk/{lexer,ast,parser,interp,disasm}.py`, `ide/server.py`,
  `samples/strings.ctk`, `samples/lists.ctk`, `run_tests.py`, `README.md`
  (in `ctecx-ade-ide`).
- `ctecx_instruct\packs\ctecx_instruct_ctecx-toolkit-007.zip` (5 parts at root).

## Verification

- `python run_tests.py` → `83/83 checks passed`.
- `python -m core.ctk.repl "print [1, 2, 3]"` → `[1, 2, 3]`;
  `python -m core.ctk.repl 'print "hi" + " x"'` → `hi x`;
  `python -m core.ctk.repl "print 3 < 5"` → `true`.
- Browser (detached `ctecx-ide dev` :8088): run output for lists/strings/
  booleans; Analyze `no diagnostics`; Listing shows `PACK/IDX` and string/
  bool literals.
- Zip contains exactly `INSTRUCT.md task.sh task.sql task.json task.assembly`;
  `task.json.manifest[*].sha256` matches.

## Owner

```
wan mohd azizi bin wan hosen, ctaxnagomi, est 2024
```