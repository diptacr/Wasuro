unit wasm.test.opcode.i64divu;

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
    test_begin('opcode.i64.div_u');

    code[0] := $80;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 10);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i64('10/3=3', popi64(ctx^.ExecutionState.Operand_Stack), 3);

    { Edge: division by zero traps }
    code[0] := $80;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_bool('div by zero traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
