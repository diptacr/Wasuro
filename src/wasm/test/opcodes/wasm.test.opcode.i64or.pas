unit wasm.test.opcode.i64or;

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
    test_begin('opcode.i64.or');

    code[0] := $84;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FF00);
    pushi64(ctx^.ExecutionState.Operand_Stack, $00FF);
    wasm.vm.tick(ctx);
    assert_i64('$FF00 or $00FF = $FFFF', popi64(ctx^.ExecutionState.Operand_Stack), $FFFF);

    code[0] := $84;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('0 or 0 = 0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
