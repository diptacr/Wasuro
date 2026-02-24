unit wasm.test.opcode.i32remu;

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
    test_begin('opcode.i32.rem_u');

    { Test: 10 mod 3 = 1 }
    code[0] := $70;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('10%3=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: $FFFFFFFF mod 3 = 0 (unsigned interpretation) }
    code[0] := $70;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);  { = $FFFFFFFF unsigned }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i32('FFFFFFFF%3=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Edge: rem by zero traps }
    code[0] := $70;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_bool('rem_by_zero_traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
