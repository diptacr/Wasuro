# WASURO

A WebAssembly virtual machine for the [Asuro](https://gitea.spexeah.com/Spexeah/Asuro) operating system, written in Standard Pascal.

WASURO parses and executes WASM binaries directly in a bare-metal kernel environment — no runtime library, no classes, no heap manager beyond what the OS provides.

## Architecture

```
src/
├── emu/               # OS emulation layer (types, console, memory, LEB128)
├── wasm/              # WASM Virtual Machine
│   ├── parser/        # WASM binary parser
│   │   └── sections/  # Section-specific parsers (type, function, export,
│   │                  #   code, global, memory, start, data, etc.)
│   ├── types/         # WASM type system, stack, and linear memory (heap)
│   ├── vm/            # VM tick loop and opcode jump table
│   └── test/          # Test suite
│       ├── infra/     # Stack, heap, LEB128 tests
│       ├── opcodes/   # Per-opcode test units
│       └── parsers/   # Per-section parser tests
└── project/           # Lazarus project files
```

### Key components

- **VM** (`wasm.vm`) — Tick-based execution loop dispatching opcodes through a 256-entry jump table.
- **Parser** (`wasm.parser`) — Validates the WASM magic/version header, then routes each binary section to its handler.
- **Stack** (`wasm.types.stack`) — Operand and control stacks supporting i32, i64, f32, f64 push/pop.
- **Heap** (`wasm.types.heap`) — Paged linear memory with read/write at 8/16/32/64-bit widths.
- **Emulation layer** (`src/emu/`) — Provides the same `types`, `console`, `lmemorymanager`, and `leb128` interfaces that exist in the real Asuro kernel, allowing development and testing on a host OS.

### Implemented opcodes

| Category | Opcodes |
|---|---|
| Control | `nop`, `unreachable`, `drop`, `select`, `return` |
| Variables | `local.get/set/tee`, `global.get/set` |
| Constants | `i32.const`, `i64.const`, `f32.const`, `f64.const` |
| i32 Arithmetic | `add`, `sub`, `mul`, `div_s/u`, `rem_s/u`, `clz`, `ctz`, `popcnt` |
| i32 Bitwise | `and`, `or`, `xor`, `shl`, `shr_s/u`, `rotl`, `rotr` |
| i32 Comparison | `eqz`, `eq`, `ne`, `lt_s/u`, `gt_s/u`, `le_s/u`, `ge_s/u` |
| i64 Arithmetic | `add`, `sub`, `mul`, `div_s/u`, `rem_s/u`, `clz`, `ctz`, `popcnt` |
| i64 Bitwise | `and`, `or`, `xor`, `shl`, `shr_s/u`, `rotl`, `rotr` |
| i64 Comparison | `eqz`, `eq`, `ne`, `lt_s/u`, `gt_s/u`, `le_s/u`, `ge_s/u` |
| f32/f64 Comparison | `eq`, `ne`, `lt`, `gt`, `le`, `ge` |
| Memory Loads | `i32/i64/f32/f64.load`, sign/zero-extending variants (8/16/32-bit) |
| Memory Stores | `i32/i64/f32/f64.store`, narrowing variants (8/16/32-bit) |
| Memory Mgmt | `memory.size`, `memory.grow` |

### Parsed sections

Type, Function, Export, Code, Global, Memory, Start, Data, Import (stub), Table (stub), Element (stub), Custom (stub).

## Constraints

- **Standard Pascal only** — no runtime library, no classes.
- **Kernel-compatible** — all arithmetic (including `shr_s`) uses manual implementations, no RTL intrinsics.
- **Emulation layer** — `src/emu/` mirrors the real Asuro kernel API; only these interfaces are available.

## Requirements

- [Free Pascal Compiler](https://www.freepascal.org/) 3.2.2+ (x86_64-win64)
- Windows (build script is a `.bat` file)

## Building

```bat
# Normal build
build.bat

# Build with test suite
build.bat test
```

Output: `bin\WASURO.exe`

## Testing

```bat
build.bat test
bin\WASURO.exe
```

Runs 374 tests across 108 test units. Exit code equals the number of failed tests (0 on success), making it CI/CD-friendly.

## License

See repository for license details.
