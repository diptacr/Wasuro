unit wasm.test.opcode.i64shl;

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
    test_begin('opcode.i64.shl');

    code[0] := $86;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 4);
    wasm.vm.tick(ctx);
    assert_i64('1 shl 4 = 16', popi64(ctx^.ExecutionState.Operand_Stack), 16);

    code[0] := $86;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 63);
    wasm.vm.tick(ctx);
    assert_i64('1 shl 63 = $8000000000000000', popi64(ctx^.ExecutionState.Operand_Stack), int64($8000000000000000));

    code[0] := $86;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('1 shl 0 = 1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
