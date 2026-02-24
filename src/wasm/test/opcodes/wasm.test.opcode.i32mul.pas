unit wasm.test.opcode.i32mul;

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
    test_begin('opcode.i32.mul');

    { Test: 3 * 7 = 21 }
    code[0] := $6C;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 7);
    wasm.vm.tick(ctx);
    assert_i32('3*7=21', popi32(ctx^.ExecutionState.Operand_Stack), 21);

    { Test: 0 * 100 = 0 }
    code[0] := $6C;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 100);
    wasm.vm.tick(ctx);
    assert_i32('0*100=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: -1 * -1 = 1 }
    code[0] := $6C;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('-1*-1=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: -2 * 3 = -6 }
    code[0] := $6C;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -2);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('-2*3=-6', popi32(ctx^.ExecutionState.Operand_Stack), -6);

    test_end;
end;

end.
