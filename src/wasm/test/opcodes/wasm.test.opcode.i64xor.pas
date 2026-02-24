unit wasm.test.opcode.i64xor;

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
    test_begin('opcode.i64.xor');

    code[0] := $85;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FF);
    pushi64(ctx^.ExecutionState.Operand_Stack, $FF);
    wasm.vm.tick(ctx);
    assert_i64('$FF xor $FF = 0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $85;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('0 xor 0 = 0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
