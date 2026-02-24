unit wasm.test.opcode.i32sub;

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
    test_begin('opcode.i32.sub');

    { Test: 10 - 3 = 7 }
    code[0] := $6B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('10-3=7', popi32(ctx^.ExecutionState.Operand_Stack), 7);

    { Test: 0 - 0 = 0 }
    code[0] := $6B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('0-0=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: 0 - 1 = -1 }
    code[0] := $6B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('0-1=-1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    { Test: 3 - 5 = -2 }
    code[0] := $6B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('3-5=-2', popi32(ctx^.ExecutionState.Operand_Stack), -2);

    test_end;
end;

end.
