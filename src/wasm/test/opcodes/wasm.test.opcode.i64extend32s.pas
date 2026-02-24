unit wasm.test.opcode.i64extend32s;

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
    test_begin('opcode.i64.extend32_s');

    code[0] := $C4;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $7FFFFFFF);
    wasm.vm.tick(ctx);
    assert_i64('extend32s($7FFFFFFF)=2147483647', popi64(ctx^.ExecutionState.Operand_Stack), 2147483647);

    code[0] := $C4;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $80000000);
    wasm.vm.tick(ctx);
    assert_i64('extend32s($80000000)=-2147483648', popi64(ctx^.ExecutionState.Operand_Stack), -2147483648);

    code[0] := $C4;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FFFFFFFF);
    wasm.vm.tick(ctx);
    assert_i64('extend32s($FFFFFFFF)=-1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
