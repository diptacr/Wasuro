# WASURO

A WebAssembly virtual machine for the [Asuro](https://gitea.spexeah.com/Spexeah/Asuro) operating system, written in Standard Pascal.

WASURO parses and executes WASM binaries directly in a bare-metal kernel environment — no runtime library, no classes, no heap manager beyond what the OS provides.

---

## Quick Start

```powershell
# Build and run the test suite (1087 unit tests)
.\build.ps1 clean test run

# Build and run all WAT end-to-end tests (9 tests, requires wabt)
$env:PATH = "C:\wabt\bin;$env:PATH"
.\build.ps1 clean e2e

# Build and run a WASM module
.\build.ps1 clean
.\bin\WASURO.exe path\to\module.wasm
```

---

## Requirements

- [Free Pascal Compiler](https://www.freepascal.org/) 3.2.2+ (x86_64-win64)
- Windows (PowerShell build scripts)
- [wabt](https://github.com/WebAssembly/wabt) 1.0.39+ (only needed for E2E tests — provides `wat2wasm`)

---

## Building

```powershell
.\build.ps1 [clean] [test] [run] [e2e] [debug] [help]
```

| Option | Description |
|--------|-------------|
| `clean` | Delete `bin/` and `lib/` before building |
| `test` | Build with the unit test suite enabled (`-dRUN_TESTS`) |
| `run` | Run `bin\WASURO.exe` after a successful build |
| `e2e` | Compile and run WAT end-to-end tests (cannot combine with `test`/`run`) |
| `debug` | Build with verbose diagnostic logging (`-dDEBUG_OUTPUT`) |
| `help` | Show usage |

Supports both positional args (`.\build.ps1 clean test run`) and PowerShell switches (`.\build.ps1 -Clean -Test -Run`).

Output binary: `bin\WASURO.exe`

---

## Testing

### Unit Tests

```powershell
.\build.ps1 clean test run
```

Runs **1087 tests** across **232 test units**. Exit code equals the number of failed tests (0 = all pass), making it CI/CD-friendly.

Tests cover every opcode, every parser section, the stack/heap/LEB128 infrastructure, the WASI glue layer, the import registry, per-context hook independence, and full binary round-trips.

### End-to-End WAT Tests

```powershell
$env:PATH = "C:\wabt\bin;$env:PATH"
.\build.ps1 clean e2e
```

Runs **9 WAT test programs** that exercise the full pipeline: compile `.wat` → `.wasm` with `wat2wasm`, execute through WASURO, and assert exit codes and stdout output.

Each WAT file declares its expectations via comment metadata:

```wat
;; @expect-exit 0
;; @expect-stdout Hello, World!
```

### Linting

```powershell
.\lint.ps1
```

Enforces that all code under `src/wasm/` uses `TWASM*` type aliases from `wasm.types.builtin` — no native Pascal types (`Integer`, `Boolean`, etc.) are allowed except in `wasm.types.builtin.pas` itself.

---

## Running a WASM Module

```powershell
.\bin\WASURO.exe path\to\module.wasm
```

WASURO will:

1. Parse and validate the WASM binary
2. Register emulation-layer OS hooks and all 46 WASI preview1 host functions into the context
3. Resolve imports against the context's host function registry
4. Locate the `_start` export and run tick-based execution to completion
5. Exit with the WASM module's exit code

---

## Integration Guide

WASURO is designed to be embedded in a kernel or host program. The `wasm` unit is the single entry point — a caller only needs `wasm` (plus `wasm.types.context` for the `PWASMProcessContext` type) to load, configure, and execute a WASM module.

The entire engine is decoupled from the OS through two abstraction layers:

- **`src/emu/`** — the OS emulation layer (swap this out for your kernel)
- **`src/wasm/types/`** — the WASM type system (all VM code uses `TWASM*` aliases, never native Pascal types)

### Lifecycle

```pascal
uses
    wasm.types.context,
    wasm;

var
    Context : PWASMProcessContext;
    Buffer  : TWASMPUInt8;  { pointer to your WASM binary in memory }
    BufEnd  : TWASMPUInt8;  { pointer past the last byte }

begin
    { 1. Initialize the VM (once per program) }
    wasm.wasm_init;

    { 2. Load the WASM binary }
    Context := wasm.wasm_load(Buffer, BufEnd);

    { 3. Register OS hooks (your kernel's implementations) }
    wasm.wasm_set_fd_write(Context, @my_kernel_fd_write);
    wasm.wasm_set_proc_exit(Context, @my_kernel_proc_exit);
    { ... etc. for any hooks you need }

    { 4. Register WASI preview1 glue (maps all 46 syscalls) }
    wasm.wasm_register_wasi_preview1(Context);

    { 5. Find _start, resolve imports, and run to completion }
    wasm.wasm_start(Context);
end.
```

### Manual Tick Loop

For cooperative scheduling or debugger integration, use `wasm_prepare_start` + `wasm_tick` instead of `wasm_start`:

```pascal
{ Set up the _start call frame without executing }
if wasm.wasm_prepare_start(Context) then begin
    { Single-step until done }
    while wasm.wasm_tick(Context) do begin
        { yield to scheduler, check watchdog, etc. }
    end;
end;
```

### Providing OS Hooks

WASI functions are split into three layers:

| Layer | Unit | Responsibility |
|-------|------|----------------|
| **OS Hooks** | `wasm.wasi.hooks` | Clean native-typed callback signatures — no WASM knowledge |
| **WASI Glue** | `wasm.wasi.preview1.fd.write`, etc. | Marshals between WASM stack/linear memory and native hook calls |
| **Registry** | `wasm.wasi.registry` | Maps `(module, function)` name pairs to glue callbacks |

Your kernel only needs to implement the **OS Hooks** layer. All hooks are per-context — different WASM contexts can have independent hook configurations. Register each hook via the `wasm` glue unit:

```pascal
uses wasm, wasm.types.context;

{ Register your kernel's implementations on a specific context }
wasm.wasm_set_fd_write(Context, @my_kernel_fd_write);
wasm.wasm_set_proc_exit(Context, @my_kernel_proc_exit);
wasm.wasm_set_clock_time_get(Context, @my_kernel_clock);
{ ... etc. }
```

Available hooks (12 total):

| Glue Function | Signature |
|---------------|-----------|
| `wasm_set_fd_write` | `function(fd: TWASMUInt32; buf: TWASMPUInt8; len: TWASMUInt32): TWASMUInt32` |
| `wasm_set_fd_read` | `function(fd: TWASMUInt32; buf: TWASMPUInt8; len: TWASMUInt32): TWASMUInt32` |
| `wasm_set_fd_close` | `function(fd: TWASMUInt32): TWASMUInt32` |
| `wasm_set_fd_seek` | `function(fd: TWASMUInt32; offset: TWASMInt64; whence: TWASMUInt32; var newoffset: TWASMUInt64): TWASMUInt32` |
| `wasm_set_proc_exit` | `procedure(code: TWASMUInt32)` |
| `wasm_set_clock_time_get` | `function(clock_id: TWASMUInt32; precision: TWASMUInt64; var time: TWASMUInt64): TWASMUInt32` |
| `wasm_set_clock_res_get` | `function(clock_id: TWASMUInt32; var resolution: TWASMUInt64): TWASMUInt32` |
| `wasm_set_random_get` | `function(buf: TWASMPUInt8; len: TWASMUInt32): TWASMUInt32` |
| `wasm_set_args_sizes_get` | `function(var count: TWASMUInt32; var buf_size: TWASMUInt32): TWASMUInt32` |
| `wasm_set_args_get` | `function(argv: TWASMPUInt32; argv_buf: TWASMPUInt8): TWASMUInt32` |
| `wasm_set_environ_sizes_get` | `function(var count: TWASMUInt32; var buf_size: TWASMUInt32): TWASMUInt32` |
| `wasm_set_environ_get` | `function(environ: TWASMPUInt32; environ_buf: TWASMPUInt8): TWASMUInt32` |

Any hook left as `nil` will cause the corresponding WASI function to return `ENOSYS` (errno 52).

### Registering Custom Host Modules

The registry is not limited to `wasi_snapshot_preview1`. You can register functions under any module name. The host function registry is per-context and dynamically grows — there is no fixed upper limit.

```pascal
uses wasm, wasm.types.context;

{ Your custom host function — pops/pushes values via the WASM operand stack }
procedure my_custom_func(Context: PWASMProcessContext);
begin
    { Pop args from Context^.ExecutionState.Operand_Stack }
    { Do work }
    { Push results back }
end;

{ Register under your own module name }
wasm.wasm_register_host_func(Context,
    'my_module', 'my_function', @my_custom_func);

{ Optionally also register WASI preview1 }
wasm.wasm_register_wasi_preview1(Context);

{ Resolve and run }
wasm.wasm_start(Context);
```

### Replacing the Emulation Layer

The `src/emu/` directory contains 4 units that abstract the host OS:

| Unit | Purpose | Your kernel provides |
|------|---------|---------------------|
| `types.pas` | Native type aliases (`uint8`, `int32`, etc.) | Your kernel's base types |
| `console.pas` | Console I/O (`writestring`, `writestringln`) | Your kernel's text output |
| `lmemorymanager.pas` | Memory allocator (`kalloc`) | Your kernel's allocator |
| `wasi.emu.hooks.pas` | WASI hook implementations | Replace with kernel-level hooks (see above) |

To port WASURO to your own kernel, replace these 4 files with implementations backed by your kernel's APIs. Everything under `src/wasm/` is OS-agnostic and should not need modification.

---

## Architecture

```
src/
├── emu/                  # OS emulation layer (swap for your kernel)
│   ├── types.pas         #   Native type aliases
│   ├── console.pas       #   Console I/O
│   ├── lmemorymanager.pas#   Memory allocator (kalloc)
│   └── wasi.emu.hooks.pas#   Host OS WASI hook implementations
├── wasm/                 # WASM Virtual Machine (OS-agnostic)
│   ├── wasm.pas          #   Top-level glue unit (single entry point)
│   ├── parser/           #   Binary parser + 13 section handlers
│   ├── types/            #   Type system, stack, heap, LEB128 (9 units)
│   ├── vm/               #   Tick loop + 181 opcode implementations
│   ├── wasi/             #   WASI preview1 (18 units)
│   │   ├── preview1/     #     15 handler units (fd.write, proc.exit, etc.)
│   │   ├── wasm.wasi.hooks.pas     # Per-context hook registration
│   │   ├── wasm.wasi.registry.pas  # Per-context host function registry
│   │   └── wasm.wasi.preview1.pas  # Bulk-registers all 46 WASI functions
│   └── test/             #   Test suite (232 units, 1087 tests)
│       ├── opcodes/      #     Per-opcode tests (180 units)
│       ├── parsers/      #     Per-section parser tests (14 units)
│       ├── binaries/     #     Binary round-trip tests (6 units)
│       ├── infra/        #     Stack, heap, LEB128 tests (3 units)
│       └── wasi/         #     WASI + registry tests (9 units)
├── project/              # Lazarus project files
└── wat/                  # End-to-end WAT test programs (9 tests)
```

### Key Components

| Component | Unit | Description |
|-----------|------|-------------|
| **Glue** | `wasm` | Top-level trampoline — single unit a caller needs to load, configure, and execute WASM modules |
| **VM** | `wasm.vm` | Tick-based execution loop dispatching through a 256-entry opcode jump table + secondary 0xFC-prefix table |
| **Parser** | `wasm.parser` | Validates WASM magic/version header, routes each section to its dedicated handler |
| **Stack** | `wasm.types.stack` | Operand and control stacks supporting i32, i64, f32, f64, v128, funcref, and externref |
| **Heap** | `wasm.types.heap` | Paged linear memory with read/write at 8/16/32/64-bit widths, `memory.grow` support |
| **Registry** | `wasm.wasi.registry` | Per-context, dynamically-growing host function registry; maps `(module, field)` name pairs to callbacks |
| **Hooks** | `wasm.wasi.hooks` | Per-context OS hook registration — each context can have independent hook configurations |
| **WASI** | `wasm.wasi.preview1` | Registers all 46 WASI preview1 functions; delegates to OS hooks or returns ENOSYS stubs |

---

## Spec Conformity

### WebAssembly MVP

WASURO implements the complete **WebAssembly 1.0 (MVP)** instruction set:

- **198 opcodes** — 180 single-byte ($00–$C4, 100%) + 18 FC-prefixed extended (100%)
- **13 of 14 binary sections** parsed (only Tag section omitted — exception handling proposal)
- All float operations are **IEEE 754 hardened** with bitwise NaN detection to avoid x87/SSE exceptions
- Saturating truncation, bulk memory, and table operations fully implemented

### WASI Preview 1

**46 of 46** `wasi_snapshot_preview1` functions registered (100% API surface):

- **15 real implementations** — fd_write, fd_read, fd_close, fd_seek, fd_prestat_get/dir_name, fd_fdstat_get, proc_exit, environ_sizes_get/get, args_sizes_get/get, clock_time_get/res_get, random_get
- **31 ENOSYS stubs** — filesystem, path, poll, scheduler, and socket operations return errno 52

### Not Yet Implemented

| Feature | Notes |
|---------|-------|
| SIMD (0xFD prefix) | ~240 v128 opcodes |
| GC (0xFB prefix) | ~40 opcodes |
| Reference types ($D0–$D6) | 7 opcodes |
| Exception handling | Tag section + try/catch opcodes |
| Tail calls | `return_call`, `return_call_indirect` |
| Full validation | Structural validation only; no full type-checking pass |

---

## Opcode Reference

| Category | Opcodes |
|----------|---------|
| Control flow | `nop`, `unreachable`, `block`, `loop`, `if`, `else`, `end`, `br`, `br_if`, `br_table`, `call`, `call_indirect`, `return` |
| Parametric | `drop`, `select`, `select t` |
| Variables | `local.get/set/tee`, `global.get/set` |
| Constants | `i32.const`, `i64.const`, `f32.const`, `f64.const` |
| i32 arithmetic | `add`, `sub`, `mul`, `div_s/u`, `rem_s/u`, `clz`, `ctz`, `popcnt` |
| i32 bitwise | `and`, `or`, `xor`, `shl`, `shr_s/u`, `rotl`, `rotr` |
| i32 comparison | `eqz`, `eq`, `ne`, `lt_s/u`, `gt_s/u`, `le_s/u`, `ge_s/u` |
| i64 arithmetic | `add`, `sub`, `mul`, `div_s/u`, `rem_s/u`, `clz`, `ctz`, `popcnt` |
| i64 bitwise | `and`, `or`, `xor`, `shl`, `shr_s/u`, `rotl`, `rotr` |
| i64 comparison | `eqz`, `eq`, `ne`, `lt_s/u`, `gt_s/u`, `le_s/u`, `ge_s/u` |
| f32 | `abs`, `neg`, `ceil`, `floor`, `trunc`, `nearest`, `sqrt`, `add`, `sub`, `mul`, `div`, `min`, `max`, `copysign`, comparisons |
| f64 | `abs`, `neg`, `ceil`, `floor`, `trunc`, `nearest`, `sqrt`, `add`, `sub`, `mul`, `div`, `min`, `max`, `copysign`, comparisons |
| Conversions | `wrap`, `extend`, `trunc`, `convert`, `demote`, `promote`, `reinterpret`, sign-extension |
| Memory | `load`/`store` (all widths), sign/zero-extending loads, narrowing stores, `memory.size`, `memory.grow` |
| 0xFC saturating | `i32.trunc_sat_f32_s/u`, `i32.trunc_sat_f64_s/u`, `i64.trunc_sat_f32_s/u`, `i64.trunc_sat_f64_s/u` |
| 0xFC bulk memory | `memory.init`, `data.drop`, `memory.copy`, `memory.fill` |
| 0xFC table | `table.init`, `elem.drop`, `table.copy`, `table.grow`, `table.size`, `table.fill` |

---

## Constraints

- **Standard Pascal only** — no runtime library, no classes
- **Kernel-compatible** — designed for ring-0 execution; all arithmetic uses manual implementations with no RTL intrinsics; an unhandled exception = system hang
- **Type decoupling** — all WASM code uses `TWASM*` types from `src/wasm/types/wasm.types.builtin.pas`, never native Pascal types
- **Emulation layer** — `src/emu/` mirrors the real Asuro kernel API; swap these 4 files to port to your own kernel

---

## License

See repository for license details.
