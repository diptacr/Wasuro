unit wasm.test.opcode.i32divu;

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
    test_begin('opcode.i32.div_u');

    { Test: 10 / 3 = 3 }
    code[0] := $6E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('10/3=3', popi32(ctx^.ExecutionState.Operand_Stack), 3);

    { Test: $FFFFFFFF / 2 = $7FFFFFFF (unsigned interpretation) }
    code[0] := $6E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);  { = $FFFFFFFF unsigned }
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);
    wasm.vm.tick(ctx);
    assert_i32('FFFFFFFF/2=7FFFFFFF', popi32(ctx^.ExecutionState.Operand_Stack), int32($7FFFFFFF));

    { Edge: div by zero traps }
    code[0] := $6E;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_bool('div_by_zero_traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
