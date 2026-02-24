unit wasm.test.opcode.localset;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.enums, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.local.set');

    { Test: set local 0 (i32) }
    code[0] := $21; { local.set }
    code[1] := $00; { index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 2, vti32);
    pushi32(ctx^.ExecutionState.Operand_Stack, 77);
    wasm.vm.tick(ctx);
    assert_i32('local 0 = 77', ctx^.ExecutionState.Locals^.Locals[0].i32Value, 77);
    assert_u32('stack empty after set', ctx^.ExecutionState.Operand_Stack^.Top, 0);

    { Test: set local 1 (i64) }
    code[0] := $21;
    code[1] := $01;
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 2, vti64);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1234567890123);
    wasm.vm.tick(ctx);
    assert_i64('local 1 = 1234567890123', ctx^.ExecutionState.Locals^.Locals[1].i64Value, 1234567890123);

    test_end;
end;

end.
