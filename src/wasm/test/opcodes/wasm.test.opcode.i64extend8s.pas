unit wasm.test.opcode.i64extend8s;

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
    test_begin('opcode.i64.extend8_s');

    code[0] := $C2;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $7F);
    wasm.vm.tick(ctx);
    assert_i64('extend8s($7F)=127', popi64(ctx^.ExecutionState.Operand_Stack), 127);

    code[0] := $C2;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $80);
    wasm.vm.tick(ctx);
    assert_i64('extend8s($80)=-128', popi64(ctx^.ExecutionState.Operand_Stack), -128);

    code[0] := $C2;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FF);
    wasm.vm.tick(ctx);
    assert_i64('extend8s($FF)=-1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
