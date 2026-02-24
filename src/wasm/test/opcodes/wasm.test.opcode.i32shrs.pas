unit wasm.test.opcode.i32shrs;

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
    test_begin('opcode.i32.shr_s');

    { Test: 16 shr_s 2 = 4 }
    code[0] := $75;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 16);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);
    wasm.vm.tick(ctx);
    assert_i32('16 shr_s 2=4', popi32(ctx^.ExecutionState.Operand_Stack), 4);

    { Test: -1 shr_s 1 = -1 (sign-extends) }
    code[0] := $75;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('-1 shr_s 1=-1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    { Test: $80000000 shr_s 31 = -1 }
    code[0] := $75;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($80000000));
    pushi32(ctx^.ExecutionState.Operand_Stack, 31);
    wasm.vm.tick(ctx);
    assert_i32('$80000000 shr_s 31=-1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
