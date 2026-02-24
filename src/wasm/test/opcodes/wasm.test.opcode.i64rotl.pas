unit wasm.test.opcode.i64rotl;

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
    test_begin('opcode.i64.rotl');

    code[0] := $89;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('1 rotl 1 = 2', popi64(ctx^.ExecutionState.Operand_Stack), 2);

    code[0] := $89;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($8000000000000000));
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('$8000000000000000 rotl 1 = 1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
