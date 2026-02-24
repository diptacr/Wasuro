unit wasm.test.opcode.select;

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
    test_begin('opcode.select');

    { Test: select with cond != 0 picks val1 }
    code[0] := $1B; { select }
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10); { val1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 20); { val2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);  { cond }
    wasm.vm.tick(ctx);
    assert_i32('cond=1 picks val1', popi32(ctx^.ExecutionState.Operand_Stack), 10);

    { Test: select with cond = 0 picks val2 }
    code[0] := $1B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10); { val1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 20); { val2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);  { cond }
    wasm.vm.tick(ctx);
    assert_i32('cond=0 picks val2', popi32(ctx^.ExecutionState.Operand_Stack), 20);

    { Test: select with large nonzero cond picks val1 }
    code[0] := $1B;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 100);
    pushi32(ctx^.ExecutionState.Operand_Stack, 200);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('cond=-1 picks val1', popi32(ctx^.ExecutionState.Operand_Stack), 100);

    test_end;
end;

end.
