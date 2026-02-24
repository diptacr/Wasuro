unit wasm.test.opcode.i64load16s;

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
    test_begin('opcode.i64.load16_s');

    code[0] := $32; { i64.load16_s }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint16(0, ctx^.ExecutionState.Memory, $FFFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i64('load16_s $FFFF = -1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
