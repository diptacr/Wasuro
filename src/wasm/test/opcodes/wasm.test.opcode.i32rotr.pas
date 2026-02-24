unit wasm.test.opcode.i32rotr;

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
    test_begin('opcode.i32.rotr');

    { Test: 1 rotr 1 = $80000000 }
    code[0] := $78;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('1 rotr 1=$80000000', popi32(ctx^.ExecutionState.Operand_Stack), int32($80000000));

    { Test: 2 rotr 1 = 1 }
    code[0] := $78;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('2 rotr 1=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: $FF rotr 8 = $FF000000 }
    code[0] := $78;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($FF));
    pushi32(ctx^.ExecutionState.Operand_Stack, 8);
    wasm.vm.tick(ctx);
    assert_i32('$FF rotr 8=$FF000000', popi32(ctx^.ExecutionState.Operand_Stack), int32($FF000000));

    test_end;
end;

end.
