unit wasm.test.opcode.i64ges;

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
    test_begin('opcode.i64.ge_s');

    code[0] := $59;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('5>=3 -> 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $59;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('3>=3 -> 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $59;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('-1<0 -> 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
