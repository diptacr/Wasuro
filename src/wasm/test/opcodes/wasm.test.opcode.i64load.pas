unit wasm.test.opcode.i64load;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64.load');

    code[0] := $29; { i64.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint64(0, ctx^.ExecutionState.Memory, uint64($CAFEBABE12345678));
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i64('load $CAFEBABE12345678', popi64(ctx^.ExecutionState.Operand_Stack), int64($CAFEBABE12345678));

    test_end;
end;

end.
