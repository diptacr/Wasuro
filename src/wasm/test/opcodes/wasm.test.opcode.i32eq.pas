unit wasm.test.opcode.i32eq;

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
    test_begin('opcode.i32.eq');

    { Test: 5 == 5 -> 1 }
    code[0] := $46;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_i32('5==5', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 5 == 6 -> 0 }
    code[0] := $46;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);
    pushi32(ctx^.ExecutionState.Operand_Stack, 6);
    wasm.vm.tick(ctx);
    assert_i32('5!=6', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: -1 == -1 -> 1 }
    code[0] := $46;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('-1==-1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
