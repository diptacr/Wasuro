unit wasm.test.opcode.localget;

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
    test_begin('opcode.local.get');

    { Test: get local 0 (i32) }
    code[0] := $20; { local.get }
    code[1] := $00; { index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 2, vti32);
    ctx^.ExecutionState.Locals^.Locals[0].i32Value := 42;
    wasm.vm.tick(ctx);
    assert_i32('get local 0 = 42', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test: get local 1 (i32) }
    code[0] := $20;
    code[1] := $01; { index 1 }
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 2, vti32);
    ctx^.ExecutionState.Locals^.Locals[1].i32Value := -100;
    wasm.vm.tick(ctx);
    assert_i32('get local 1 = -100', popi32(ctx^.ExecutionState.Operand_Stack), -100);

    { Test: get local i64 }
    code[0] := $20;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_test_locals(ctx, 1, vti64);
    ctx^.ExecutionState.Locals^.Locals[0].i64Value := 9876543210;
    wasm.vm.tick(ctx);
    assert_i64('get local i64', popi64(ctx^.ExecutionState.Operand_Stack), 9876543210);

    test_end;
end;

end.
