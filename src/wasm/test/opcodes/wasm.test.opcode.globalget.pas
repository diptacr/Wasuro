unit wasm.test.opcode.globalget;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.global.get');

    { Test: get global 0 (i32) }
    code[0] := $23; { global.get }
    code[1] := $00; { index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_test_globals(ctx, 2, vti32, false);
    ctx^.ExecutionState.Globals^.Globals[0].Value.i32Value := 42;
    wasm.vm.tick(ctx);
    assert_i32('get global 0 = 42', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test: get global 1 (i64) }
    code[0] := $23;
    code[1] := $01;
    ctx := make_test_context(@code[0], 2);
    setup_test_globals(ctx, 2, vti64, false);
    ctx^.ExecutionState.Globals^.Globals[1].Value.i64Value := 999999;
    wasm.vm.tick(ctx);
    assert_i64('get global 1 = 999999', popi64(ctx^.ExecutionState.Operand_Stack), 999999);

    test_end;
end;

end.
