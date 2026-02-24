unit wasm.test.opcode.i64store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

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

    test_end;
end;

end.
