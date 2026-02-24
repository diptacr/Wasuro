unit wasm.test.opcode.f64reinterpreti64;

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
    test_begin('opcode.f64.reinterpret_i64');

    code[0] := $BF;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($3FF0000000000000));
    wasm.vm.tick(ctx);
    assert_f64('reinterpret($3FF0000000000000)=1.0', popf64(ctx^.ExecutionState.Operand_Stack), 1.0);

    code[0] := $BF;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_f64('reinterpret(0)=0.0', popf64(ctx^.ExecutionState.Operand_Stack), 0.0);

    code[0] := $BF;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($4000000000000000));
    wasm.vm.tick(ctx);
    assert_f64('reinterpret($4000000000000000)=2.0', popf64(ctx^.ExecutionState.Operand_Stack), 2.0);

    test_end;
end;

end.
