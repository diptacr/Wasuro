unit wasm.test.wasi.random;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.heap,
    wasm.types.wasi, wasm.wasi.hooks,
    wasm.wasi.preview1.random,
    wasm.test.framework;

var
    captured_buf : TWASMPUInt8;
    captured_len : TWASMUInt32;

function mock_random_get(buf: TWASMPUInt8;
                         len: TWASMUInt32): TWASMUInt32;
var
    i: TWASMUInt32;
begin
    captured_buf := buf;
    captured_len := len;
    { Fill with deterministic pattern for testing }
    for i := 0 to len - 1 do
        buf[i] := TWASMUInt8((i + 42) and $FF);
    mock_random_get := WASI_ESUCCESS;
end;

procedure run;
var
    code : array[0..3] of TWASMUInt8;
    ctx  : PWASMProcessContext;
    os   : PWASMStack;
    mem  : PWasmHeap;
    errno: TWASMInt32;
    b    : TWASMUInt8;
begin
    test_begin('wasi.random');

    { ------------------------------------------------------------------ }
    { Test 1: random_get with hook fills linear memory                   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.hooks.register_random_get(ctx, @mock_random_get);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    { random_get(buf=200, buf_len=4) }
    wasm.types.stack.pushi32(os, 200);  { buf ptr in linear memory }
    wasm.types.stack.pushi32(os, 4);    { buf_len }

    wasm.wasi.preview1.random._WASI_random_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('random_get returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    assert_u32('random_get len=4', captured_len, 4);

    { Verify bytes written to linear memory }
    wasm.types.heap.read_uint8(200, mem, @b);
    assert_u32('random_get byte 0', TWASMUInt32(b), (0 + 42) and $FF);
    wasm.types.heap.read_uint8(201, mem, @b);
    assert_u32('random_get byte 1', TWASMUInt32(b), (1 + 42) and $FF);
    wasm.types.heap.read_uint8(202, mem, @b);
    assert_u32('random_get byte 2', TWASMUInt32(b), (2 + 42) and $FF);
    wasm.types.heap.read_uint8(203, mem, @b);
    assert_u32('random_get byte 3', TWASMUInt32(b), (3 + 42) and $FF);

    { ------------------------------------------------------------------ }
    { Test 2: random_get with zero length                                }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 100);  { buf }
    wasm.types.stack.pushi32(os, 0);    { buf_len = 0 }

    wasm.wasi.preview1.random._WASI_random_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('random_get zero len returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));

    { ------------------------------------------------------------------ }
    { Test 3: random_get without hook returns ENOSYS                     }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 100);  { buf }
    wasm.types.stack.pushi32(os, 8);    { buf_len }

    wasm.wasi.preview1.random._WASI_random_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('random_get no hook returns ENOSYS', errno, TWASMInt32(WASI_ENOSYS));

    test_end;
end;

end.
