unit wasm.test.opcode.i64remu;

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
    test_begin('opcode.i64.rem_u');

    code[0] := $82;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 10);
    pushi64(ctx^.ExecutionState.Operand_Stack, 3);
    wasm.vm.tick(ctx);
    assert_i64('10 mod 3 = 1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    { Edge: rem by zero traps }
    code[0] := $82;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_bool('rem by zero traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
