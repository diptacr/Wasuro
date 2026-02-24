# WASURO

A WebAssembly virtual machine for the [Asuro](https://gitea.spexeah.com/Spexeah/Asuro) operating system, written in Standard Pascal.

WASURO parses and executes WASM binaries directly in a bare-metal kernel environment — no runtime library, no classes, no heap manager beyond what the OS provides.

## Architecture

```
src/
├── emu/               # OS emulation layer (types, console, memory, LEB128)
├── wasm/              # WASM Virtual Machine
│   ├── parser/        # WASM binary parser
│   │   └── sections/  # Section-specific parsers (13 section types)
│   ├── types/         # WASM type system, stack, and linear memory (heap)
│   ├── vm/            # VM tick loop and opcode jump tables
│   │   └── opcodes/   # 198 opcode implementations + FC dispatch
│   └── test/          # Test suite (223 test units, 876 tests)
│       ├── infra/     # Stack, heap, LEB128 tests
│       ├── opcodes/   # Per-opcode test units
│       ├── parsers/   # Per-section parser tests
│       └── binaries/  # End-to-end WASM binary tests
└── project/           # Lazarus project files
```

### Key Components

- **VM** (`wasm.vm`) — Tick-based execution loop dispatching opcodes through a 256-entry jump table, plus a secondary 0xFC-prefix table for extended instructions.
- **Parser** (`wasm.parser`) — Validates the WASM magic/version header, then routes each binary section to its dedicated handler.
- **Stack** (`wasm.types.stack`) — Operand and control stacks supporting i32, i64, f32, f64, v128, funcref, and externref push/pop.
- **Heap** (`wasm.types.heap`) — Paged linear memory with read/write at 8/16/32/64-bit widths.
- **Emulation layer** (`src/emu/`) — Provides the same `types`, `console`, `lmemorymanager`, and `leb128` interfaces that exist in the real Asuro kernel, allowing development and testing on a host OS.

### Opcode Coverage

**198 opcodes implemented** — 180 single-byte MVP opcodes (100%) + 18 FC-prefixed extended opcodes (100%).

| Category | Opcodes |
|---|---|
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
| f32 full | `abs`, `neg`, `ceil`, `floor`, `trunc`, `nearest`, `sqrt`, `add`, `sub`, `mul`, `div`, `min`, `max`, `copysign`, `eq`, `ne`, `lt`, `gt`, `le`, `ge` |
| f64 full | `abs`, `neg`, `ceil`, `floor`, `trunc`, `nearest`, `sqrt`, `add`, `sub`, `mul`, `div`, `min`, `max`, `copysign`, `eq`, `ne`, `lt`, `gt`, `le`, `ge` |
| Conversions | `i32.wrap_i64`, `i32.trunc_f32_s/u`, `i32.trunc_f64_s/u`, `i64.extend_i32_s/u`, `i64.trunc_f32_s/u`, `i64.trunc_f64_s/u`, `f32.convert_i32_s/u`, `f32.convert_i64_s/u`, `f32.demote_f64`, `f64.convert_i32_s/u`, `f64.convert_i64_s/u`, `f64.promote_f32`, `i32.reinterpret_f32`, `i64.reinterpret_f64`, `f32.reinterpret_i32`, `f64.reinterpret_i64`, `i32.extend8_s`, `i32.extend16_s`, `i64.extend8_s`, `i64.extend16_s`, `i64.extend32_s` |
| Memory loads | `i32/i64/f32/f64.load`, sign/zero-extending variants (8/16/32-bit) |
| Memory stores | `i32/i64/f32/f64.store`, narrowing variants (8/16/32-bit) |
| Memory mgmt | `memory.size`, `memory.grow` |
| 0xFC sat. trunc | `i32.trunc_sat_f32_s/u`, `i32.trunc_sat_f64_s/u`, `i64.trunc_sat_f32_s/u`, `i64.trunc_sat_f64_s/u` |
| 0xFC bulk memory | `memory.init`, `data.drop`, `memory.copy`, `memory.fill` |
| 0xFC table ops | `table.init`, `elem.drop`, `table.copy`, `table.grow`, `table.size`, `table.fill` |

All float operations are IEEE 754 hardened with bitwise NaN detection to avoid FPC x64 `EInvalidOp` exceptions.

### Parsed Sections

| ID | Section | Status |
|----|---------|--------|
| 0 | Custom | Skipped (per spec) |
| 1 | Type | Full |
| 2 | Import | Full |
| 3 | Function | Full |
| 4 | Table | Full |
| 5 | Memory | Full |
| 6 | Global | Full |
| 7 | Export | Full |
| 8 | Start | Full |
| 9 | Element | Full |
| 10 | Code | Full |
| 11 | Data | Full |
| 12 | DataCount | Full |

## Constraints

- **Standard Pascal only** — no runtime library, no classes.
- **Kernel-compatible** — designed for ring-0 execution; all arithmetic uses manual implementations with no RTL intrinsics. An unhandled exception means a system hang.
- **Emulation layer** — `src/emu/` mirrors the real Asuro kernel API; only these interfaces are available.
- **Type decoupling** — all WASM code uses types from `src/wasm/types/`, providing a clean abstraction between the WASM VM and the host OS.

## Requirements

- [Free Pascal Compiler](https://www.freepascal.org/) 3.2.2+ (x86_64-win64)
- Windows (PowerShell build script)

## Building

```powershell
# Normal build
.\build.ps1

# Clean build
.\build.ps1 clean

# Build with test suite
.\build.ps1 clean test run

# Build with debug output (verbose diagnostic logging)
.\build.ps1 clean debug test run
```

Supports both positional args (`.\build.ps1 clean test run`) and PowerShell switches (`.\build.ps1 -Clean -Test -Run`).

Output: `bin\WASURO.exe`

## Running

```powershell
# Run a WASM module
.\bin\WASURO.exe path\to\module.wasm
```

After execution halts, WASURO prints the VM state including IP, running status, and operand/control stack contents.

## Testing

```powershell
.\build.ps1 clean test run
```

Runs **876 tests** across **223 test units**. Exit code equals the number of failed tests (0 on success), making it CI/CD-friendly.

## License

See repository for license details.
