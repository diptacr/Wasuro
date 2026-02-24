unit wasm.test.opcode.i64eq;

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
    test_begin('opcode.i64.eq');

    code[0] := $51;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('5==5 -> 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $51;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    pushi64(ctx^.ExecutionState.Operand_Stack, 6);
    wasm.vm.tick(ctx);
    assert_i32('5==6 -> 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $51;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('-1==-1 -> 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
