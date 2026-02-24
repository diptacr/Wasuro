unit wasm.test.opcode.i32load16s;

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
    test_begin('opcode.i32.load16_s');

    { Test: $FFFF sign-extends to -1 }
    code[0] := $2E; { i32.load16_s }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint16(0, ctx^.ExecutionState.Memory, $FFFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load16_s $FFFF = -1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    { Test: $7FFF sign-extends to 32767 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint16(0, ctx^.ExecutionState.Memory, $7FFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load16_s $7FFF = 32767', popi32(ctx^.ExecutionState.Operand_Stack), 32767);

    test_end;
end;

end.
