unit wasm.test.opcode.drop;

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
    test_begin('opcode.drop');

    { Test: drop removes top of stack }
    code[0] := $1A; { drop }
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 42);
    pushi32(ctx^.ExecutionState.Operand_Stack, 99);
    wasm.vm.tick(ctx);
    assert_u32('stack top decreased', ctx^.ExecutionState.Operand_Stack^.Top, 1);
    assert_i32('remaining value', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test: drop on empty stack traps }
    code[0] := $1A;
    ctx := make_test_context(@code[0], 1);
    wasm.vm.tick(ctx);
    assert_bool('empty drop traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
