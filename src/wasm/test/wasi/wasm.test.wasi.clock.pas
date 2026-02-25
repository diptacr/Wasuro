unit wasm.test.wasi.clock;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.heap,
    wasm.types.wasi, wasm.wasi.hooks,
    wasm.wasi.preview1.clock,
    wasm.test.framework;

var
    last_clock_id  : TWASMUInt32;
    last_precision : TWASMUInt64;

function mock_clock_time_get(clock_id: TWASMUInt32;
                             precision: TWASMUInt64;
                             var time: TWASMUInt64): TWASMUInt32;
begin
    last_clock_id := clock_id;
    last_precision := precision;
    time := 1234567890000000000;  { ~1.23 seconds in nanoseconds }
    mock_clock_time_get := WASI_ESUCCESS;
end;

function mock_clock_res_get(clock_id: TWASMUInt32;
                            var resolution: TWASMUInt64): TWASMUInt32;
begin
    last_clock_id := clock_id;
    resolution := 1000000; { 1ms in nanoseconds }
    mock_clock_res_get := WASI_ESUCCESS;
end;

procedure run;
var
    code : array[0..3] of TWASMUInt8;
    ctx  : PWASMProcessContext;
    os   : PWASMStack;
    mem  : PWasmHeap;
    errno: TWASMInt32;
    time_lo, time_hi : TWASMUInt32;
begin
    test_begin('wasi.clock');

    { ------------------------------------------------------------------ }
    { Test 1: clock_time_get with hook — returns time in linear memory   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.hooks.register_clock_time_get(ctx, @mock_clock_time_get);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    { clock_time_get(id=0 [realtime], precision=1000, time_ptr=400) }
    wasm.types.stack.pushi32(os, 0);        { clock_id = REALTIME }
    wasm.types.stack.pushi64(os, 1000);     { precision }
    wasm.types.stack.pushi32(os, 400);      { time_ptr }

    wasm.wasi.preview1.clock._WASI_clock_time_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('clock_time_get returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    assert_u32('clock_time_get clock_id=0', last_clock_id, 0);
    assert_u64('clock_time_get precision=1000', last_precision, 1000);

    { Verify 64-bit time written to linear memory (little-endian) }
    { 1234567890000000000 = 0x112210F4_768DB400 }
    wasm.types.heap.read_uint32(400, mem, @time_lo);
    wasm.types.heap.read_uint32(404, mem, @time_hi);
    assert_u32('clock_time_get time lo', time_lo, TWASMUInt32($768DB400));
    assert_u32('clock_time_get time hi', time_hi, TWASMUInt32($112210F4));

    { ------------------------------------------------------------------ }
    { Test 2: clock_time_get without hook returns ENOSYS                 }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 0);    { clock_id }
    wasm.types.stack.pushi64(os, 0);    { precision }
    wasm.types.stack.pushi32(os, 0);    { time_ptr }

    wasm.wasi.preview1.clock._WASI_clock_time_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('clock_time_get no hook returns ENOSYS', errno, TWASMInt32(WASI_ENOSYS));

    { ------------------------------------------------------------------ }
    { Test 3: clock_res_get with hook — returns resolution               }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.hooks.register_clock_res_get(ctx, @mock_clock_res_get);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    { clock_res_get(id=1 [monotonic], resolution_ptr=500) }
    wasm.types.stack.pushi32(os, 1);    { clock_id = MONOTONIC }
    wasm.types.stack.pushi32(os, 500);  { resolution_ptr }

    wasm.wasi.preview1.clock._WASI_clock_res_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('clock_res_get returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    assert_u32('clock_res_get clock_id=1', last_clock_id, 1);

    { Verify 64-bit resolution written to linear memory }
    wasm.types.heap.read_uint32(500, mem, @time_lo);
    wasm.types.heap.read_uint32(504, mem, @time_hi);
    assert_u32('clock_res_get resolution lo', time_lo, 1000000);
    assert_u32('clock_res_get resolution hi', time_hi, 0);

    { ------------------------------------------------------------------ }
    { Test 4: clock_res_get without hook returns ENOSYS                  }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 0);    { clock_id }
    wasm.types.stack.pushi32(os, 0);    { resolution_ptr }

    wasm.wasi.preview1.clock._WASI_clock_res_get(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('clock_res_get no hook returns ENOSYS', errno, TWASMInt32(WASI_ENOSYS));

    test_end;
end;

end.
