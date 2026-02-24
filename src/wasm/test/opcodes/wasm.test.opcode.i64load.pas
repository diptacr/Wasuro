unit wasm.test.opcode.i64load;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64.load');

    code[0] := $29; { i64.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint64(0, ctx^.ExecutionState.Memory, TWASMUInt64($CAFEBABE12345678));
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i64('load $CAFEBABE12345678', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($CAFEBABE12345678));

    { Non-zero base address }
    code[0] := $29;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint64(64, ctx^.ExecutionState.Memory, TWASMUInt64($0102030405060708));
    pushi32(ctx^.ExecutionState.Operand_Stack, 64);
    wasm.vm.tick(ctx);
    assert_i64('load at addr 64', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($0102030405060708));

    { Non-zero offset }
    code[0] := $29;
    code[1] := $00;
    code[2] := $20; { offset = 32 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint64(32, ctx^.ExecutionState.Memory, TWASMUInt64($AAAAAAAAAAAAAAAA));
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('load with offset=32', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($AAAAAAAAAAAAAAAA));

    { OOB trap }
    code[0] := $29;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    wasm.vm.tick(ctx);
    assert_true('OOB traps', ctx^.ExecutionState.Running = false);

    { Boundary: last valid 8-byte read at $FFF8 }
    code[0] := $29;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint64($FFF8, ctx^.ExecutionState.Memory, TWASMUInt64($1122334455667788));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFF8));
    wasm.vm.tick(ctx);
    assert_i64('load at boundary', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($1122334455667788));

    { OOB: at $FFF9 needs 8 bytes, only 7 remain }
    code[0] := $29;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFF9));
    wasm.vm.tick(ctx);
    assert_true('OOB at boundary traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
