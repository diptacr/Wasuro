unit wasm.test.opcode.i64add;

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
    test_begin('opcode.i64.add');

    code[0] := $7C;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    pushi64(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i64('3+5=8', popi64(ctx^.ExecutionState.Operand_Stack), 8);

    code[0] := $7C;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('0+0=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $7C;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('-1+1=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
