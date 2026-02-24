unit wasm.test.opcode.i32ne;

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
    test_begin('opcode.i32.ne');

    { Test: 5 != 6 -> 1 }
    code[0] := $47;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 6);
    wasm.vm.tick(ctx);
    assert_i32('5!=6', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 5 != 5 -> 0 }
    code[0] := $47;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('5==5', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: 0 != -1 -> 1 }
    code[0] := $47;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('0!=-1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
