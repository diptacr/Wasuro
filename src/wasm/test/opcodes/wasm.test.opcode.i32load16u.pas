unit wasm.test.opcode.i32load16u;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.load16_u');

    code[0] := $2F; { i32.load16_u }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint16(0, ctx^.ExecutionState.Memory, $FFFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load16_u $FFFF = 65535', popi32(ctx^.ExecutionState.Operand_Stack), 65535);

    test_end;
end;

end.
