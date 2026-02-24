unit wasm.test.opcode.i64extend16s;

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
    test_begin('opcode.i64.extend16_s');

    code[0] := $C3;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $7FFF);
    wasm.vm.tick(ctx);
    assert_i64('extend16s($7FFF)=32767', popi64(ctx^.ExecutionState.Operand_Stack), 32767);

    code[0] := $C3;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $8000);
    wasm.vm.tick(ctx);
    assert_i64('extend16s($8000)=-32768', popi64(ctx^.ExecutionState.Operand_Stack), -32768);

    code[0] := $C3;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FFFF);
    wasm.vm.tick(ctx);
    assert_i64('extend16s($FFFF)=-1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
