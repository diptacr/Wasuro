unit wasm.test.opcode.i32gtu;

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
    test_begin('opcode.i32.gt_u');

    { Test: 5 > 3 -> 1 (unsigned) }
    code[0] := $4B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('5>3', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 3 > 5 -> 0 }
    code[0] := $4B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('3<=5', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: -1 (0xFFFFFFFF) > 0 -> 1 (unsigned: max > 0) }
    code[0] := $4B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('0xFFFFFFFF>0', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
