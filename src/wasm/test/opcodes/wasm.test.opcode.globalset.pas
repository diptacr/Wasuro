unit wasm.test.opcode.globalset;

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
    test_begin('opcode.global.set');

    { Test: set mutable global 0 (i32) }
    code[0] := $24; { global.set }
    code[1] := $00; { index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_test_globals(ctx, 1, vti32, true);
    pushi32(ctx^.ExecutionState.Operand_Stack, 77);
    wasm.vm.tick(ctx);
    assert_i32('mutable global 0 set to 77', ctx^.ExecutionState.Globals^.Globals[0].Value.i32Value, 77);
    assert_true('stack empty after set', ctx^.ExecutionState.Operand_Stack^.Top = 0);

    { Test: set immutable global traps }
    code[0] := $24;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_test_globals(ctx, 1, vti32, false);
    pushi32(ctx^.ExecutionState.Operand_Stack, 99);
    wasm.vm.tick(ctx);
    assert_true('immutable global set traps', ctx^.ExecutionState.Running = false);

    { Test: set mutable global (i64) }
    code[0] := $24;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_test_globals(ctx, 1, vti64, true);
    pushi64(ctx^.ExecutionState.Operand_Stack, 123456789);
    wasm.vm.tick(ctx);
    assert_i64('mutable global 0 set i64', ctx^.ExecutionState.Globals^.Globals[0].Value.i64Value, 123456789);

    test_end;
end;

end.
