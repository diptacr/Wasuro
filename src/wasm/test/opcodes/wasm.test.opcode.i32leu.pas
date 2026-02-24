unit wasm.test.opcode.i32leu;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.le_u');

    { Test: 3 <= 5 -> 1 (unsigned) }
    code[0] := $4D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('3<=5', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 3 <= 3 -> 1 }
    code[0] := $4D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('3<=3', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 5 <= 3 -> 0 }
    code[0] := $4D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('5>3', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
