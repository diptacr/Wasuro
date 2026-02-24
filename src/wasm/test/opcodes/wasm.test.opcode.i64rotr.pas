unit wasm.test.opcode.i64rotr;

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
    test_begin('opcode.i64.rotr');

    code[0] := $8A;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('1 rotr 1 = $8000000000000000', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($8000000000000000));

    code[0] := $8A;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 2);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('2 rotr 1 = 1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
