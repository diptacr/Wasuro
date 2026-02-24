unit wasm.test.opcode.selecttyped;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.select_typed');

    { Test: cond=1 picks val1 }
    code[0] := $1C;
    code[1] := $01;
    code[2] := $7F;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);  { val1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 20);  { val2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { cond }
    wasm.vm.tick(ctx);
    assert_i32('cond=1 picks val1', popi32(ctx^.ExecutionState.Operand_Stack), 10);

    { Test: cond=0 picks val2 }
    code[0] := $1C;
    code[1] := $01;
    code[2] := $7F;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);  { val1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 20);  { val2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { cond }
    wasm.vm.tick(ctx);
    assert_i32('cond=0 picks val2', popi32(ctx^.ExecutionState.Operand_Stack), 20);

    { Test: cond=-1 (nonzero) picks val1 }
    code[0] := $1C;
    code[1] := $01;
    code[2] := $7F;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 100); { val1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 200); { val2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);  { cond }
    wasm.vm.tick(ctx);
    assert_i32('cond=-1 picks val1', popi32(ctx^.ExecutionState.Operand_Stack), 100);

    test_end;
end;

end.
