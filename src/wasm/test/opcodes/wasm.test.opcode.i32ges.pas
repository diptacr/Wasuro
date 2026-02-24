unit wasm.test.opcode.i32ges;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.ge_s');

    { Test: 5 >= 3 -> 1 (signed) }
    code[0] := $4E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('5>=3', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 3 >= 3 -> 1 }
    code[0] := $4E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('3>=3', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: -1 >= 0 -> 0 (signed) }
    code[0] := $4E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('-1<0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
