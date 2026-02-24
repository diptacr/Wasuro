unit wasm.test.opcode.localtee;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.local.tee');

    { Test: tee local 0 - sets local AND keeps value on stack }
    code[0] := $22; { local.tee }
    code[1] := $00; { index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 1, vti32);
    pushi32(ctx^.ExecutionState.Operand_Stack, 55);
    wasm.vm.tick(ctx);
    assert_i32('local 0 = 55', ctx^.ExecutionState.Locals^.Locals[0].i32Value, 55);
    assert_u32('value still on stack', ctx^.ExecutionState.Operand_Stack^.Top, 1);
    assert_i32('stack value = 55', popi32(ctx^.ExecutionState.Operand_Stack), 55);

    test_end;
end;

end.
