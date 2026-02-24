unit wasm.test.opcode.i32divs;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.div_s');

    { Test: 10 / 3 = 3 }
    code[0] := $6D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('10/3=3', popi32(ctx^.ExecutionState.Operand_Stack), 3);

    { Test: -7 / 2 = -3 }
    code[0] := $6D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -7);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);
    wasm.vm.tick(ctx);
    assert_i32('-7/2=-3', popi32(ctx^.ExecutionState.Operand_Stack), -3);

    { Test: 7 / -2 = -3 }
    code[0] := $6D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 7);
    pushi32(ctx^.ExecutionState.Operand_Stack, -2);
    wasm.vm.tick(ctx);
    assert_i32('7/-2=-3', popi32(ctx^.ExecutionState.Operand_Stack), -3);

    { Edge: div by zero traps }
    code[0] := $6D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_bool('div_by_zero_traps', ctx^.ExecutionState.Running, false);

    { Edge: $80000000 / -1 traps (overflow) }
    code[0] := $6D;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($80000000));
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_bool('overflow_traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
