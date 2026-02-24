unit wasm.test.opcode.i32add;

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
    test_begin('opcode.i32.add');

    { Test: 3 + 5 = 8 }
    code[0] := $6A;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('3+5=8', popi32(ctx^.ExecutionState.Operand_Stack), 8);

    { Test: 0 + 0 = 0 }
    code[0] := $6A;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('0+0=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: -1 + 1 = 0 }
    code[0] := $6A;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('-1+1=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: overflow $7FFFFFFF + 1 = $80000000 }
    code[0] := $6A;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($7FFFFFFF));
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('overflow', popi32(ctx^.ExecutionState.Operand_Stack), int32($80000000));

    test_end;
end;

end.
