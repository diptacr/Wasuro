unit wasm.test.opcode.i32rotl;

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
    test_begin('opcode.i32.rotl');

    { Test: 1 rotl 1 = 2 }
    code[0] := $77;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('1 rotl 1=2', popi32(ctx^.ExecutionState.Operand_Stack), 2);

    { Test: $80000000 rotl 1 = 1 }
    code[0] := $77;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($80000000));
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('$80000000 rotl 1=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: $FF000000 rotl 8 = $000000FF }
    code[0] := $77;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($FF000000));
    pushi32(ctx^.ExecutionState.Operand_Stack, 8);
    wasm.vm.tick(ctx);
    assert_i32('$FF000000 rotl 8=$FF', popi32(ctx^.ExecutionState.Operand_Stack), int32($000000FF));

    test_end;
end;

end.
