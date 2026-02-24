unit wasm.test.opcode.i64mul;

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
    test_begin('opcode.i64.mul');

    code[0] := $7E;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    pushi64(ctx^.ExecutionState.Operand_Stack, 7);
    wasm.vm.tick(ctx);
    assert_i64('3*7=21', popi64(ctx^.ExecutionState.Operand_Stack), 21);

    code[0] := $7E;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    pushi64(ctx^.ExecutionState.Operand_Stack, 100);
    wasm.vm.tick(ctx);
    assert_i64('0*100=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $7E;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -2);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i64('-2*3=-6', popi64(ctx^.ExecutionState.Operand_Stack), -6);

    test_end;
end;

end.
