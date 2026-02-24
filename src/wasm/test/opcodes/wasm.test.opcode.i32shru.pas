unit wasm.test.opcode.i32shru;

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
    test_begin('opcode.i32.shr_u');

    { Test: 16 shr_u 2 = 4 }
    code[0] := $76;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 16);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);
    wasm.vm.tick(ctx);
    assert_i32('16 shr_u 2=4', popi32(ctx^.ExecutionState.Operand_Stack), 4);

    { Test: -1 shr_u 1 = $7FFFFFFF }
    code[0] := $76;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('-1 shr_u 1=$7FFFFFFF', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($7FFFFFFF));

    { Test: $80000000 shr_u 31 = 1 }
    code[0] := $76;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($80000000));
    pushi32(ctx^.ExecutionState.Operand_Stack, 31);
    wasm.vm.tick(ctx);
    assert_i32('$80000000 shr_u 31=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
