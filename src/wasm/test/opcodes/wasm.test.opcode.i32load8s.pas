unit wasm.test.opcode.i32load8s;

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
    test_begin('opcode.i32.load8_s');

    { Test: $FF sign-extends to -1 }
    code[0] := $2C; { i32.load8_s }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint8(0, ctx^.ExecutionState.Memory, $FF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load8_s $FF = -1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    { Test: $7F sign-extends to 127 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint8(0, ctx^.ExecutionState.Memory, $7F);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load8_s $7F = 127', popi32(ctx^.ExecutionState.Operand_Stack), 127);

    test_end;
end;

end.
