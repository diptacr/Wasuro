unit wasm.test.opcode.i32store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    readBack : TWASMUInt32;
begin
    test_begin('opcode.i32.store');

    code[0] := $36; { i32.store }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);              { address }
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($DEADBEEF)); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(0, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('stored DEADBEEF', readBack, $DEADBEEF);

    { Non-zero base address }
    code[0] := $36;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 200);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($CAFEBABE));
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(200, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('store at addr 200', readBack, $CAFEBABE);

    { Non-zero offset }
    code[0] := $36;
    code[1] := $00;
    code[2] := $10; { offset = 16 }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base = 0, effective = 16 }
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($11223344));
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(16, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('store with offset=16', readBack, $11223344);

    { OOB trap }
    code[0] := $36;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFFFFFFF));
    wasm.vm.tick(ctx);
    assert_true('store OOB traps', ctx^.ExecutionState.Running = false);

    { Boundary: last valid 4-byte write at $FFFC }
    code[0] := $36;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFFC));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($AABBCCDD));
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32($FFFC, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('store at boundary', readBack, $AABBCCDD);

    test_end;
end;

end.
