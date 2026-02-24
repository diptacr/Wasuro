unit wasm.test.opcode.f64const;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..8] of TWASMUInt8;
    ctx : PWASMProcessContext;
    d : TWASMDouble;
begin
    test_begin('opcode.f64const');

    { Test: f64.const 2.718281828 }
    code[0] := $44; { f64.const }
    d := 2.718281828;
    move(d, code[1], 8);
    ctx := make_test_context(@code[0], 9);
    wasm.vm.tick(ctx);
    assert_f64('const 2.718281828', popf64(ctx^.ExecutionState.Operand_Stack), 2.718281828);

    { Test: f64.const 0.0 }
    d := 0.0;
    move(d, code[1], 8);
    ctx := make_test_context(@code[0], 9);
    wasm.vm.tick(ctx);
    assert_f64('const 0.0', popf64(ctx^.ExecutionState.Operand_Stack), 0.0);

    { Test: f64.const -99.5 }
    d := -99.5;
    move(d, code[1], 8);
    ctx := make_test_context(@code[0], 9);
    wasm.vm.tick(ctx);
    assert_f64('const -99.5', popf64(ctx^.ExecutionState.Operand_Stack), -99.5);

    test_end;
end;

end.
