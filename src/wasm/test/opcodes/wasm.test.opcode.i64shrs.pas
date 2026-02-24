unit wasm.test.opcode.i64shrs;

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
    test_begin('opcode.i64.shr_s');

    code[0] := $87;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 16);
    pushi64(ctx^.ExecutionState.Operand_Stack, 2);
    wasm.vm.tick(ctx);
    assert_i64('16 shr_s 2 = 4', popi64(ctx^.ExecutionState.Operand_Stack), 4);

    code[0] := $87;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('-1 shr_s 1 = -1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
