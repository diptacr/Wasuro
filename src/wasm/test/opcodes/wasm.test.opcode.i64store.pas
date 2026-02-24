unit wasm.test.opcode.i64store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    readBack : TWASMUInt64;
begin
    test_begin('opcode.i64.store');

    code[0] := $37; { i64.store }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);                        { address }
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($CAFEBABE12345678)); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint64(0, ctx^.ExecutionState.Memory, @readBack);
    assert_u64('stored CAFEBABE12345678', readBack, TWASMUInt64($CAFEBABE12345678));

    { Non-zero offset }
    code[0] := $37;
    code[1] := $00;
    code[2] := $08; { offset = 8 }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($AABBCCDDAABBCCDD));
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint64(8, ctx^.ExecutionState.Memory, @readBack);
    assert_u64('store with offset=8', readBack, TWASMUInt64($AABBCCDDAABBCCDD));

    { OOB trap }
    code[0] := $37;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('store OOB traps', ctx^.ExecutionState.Running = false);

    { Boundary: last valid 8-byte write at $FFF8 }
    code[0] := $37;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFF8));
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($1122334455667788));
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint64($FFF8, ctx^.ExecutionState.Memory, @readBack);
    assert_u64('store at boundary', readBack, TWASMUInt64($1122334455667788));

    test_end;
end;

end.
