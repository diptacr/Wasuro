unit wasm.test.opcode.i64gtu;

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
    test_begin('opcode.i64.gt_u');

    code[0] := $56;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('5>3 -> 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $56;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('3<=5 -> 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
