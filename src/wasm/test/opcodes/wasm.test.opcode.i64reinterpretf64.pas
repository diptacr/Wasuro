unit wasm.test.opcode.i64reinterpretf64;

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
    test_begin('opcode.i64.reinterpret_f64');

    code[0] := $BD;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i64('reinterpret(1.0)', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($3FF0000000000000));

    code[0] := $BD;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_i64('reinterpret(0.0)', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $BD;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_i64('reinterpret(-1.0)', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64($BFF0000000000000));

    test_end;
end;

end.
