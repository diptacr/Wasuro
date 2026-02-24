unit wasm.test.opcode.f64neg;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits, resultBits : TWASMUInt64;
    resultVal : TWASMDouble;
begin
    test_begin('opcode.f64.neg');

    code[0] := $9A;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_f64('neg(3.5)=-3.5', popf64(ctx^.ExecutionState.Operand_Stack), -3.5);

    code[0] := $9A;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -3.5);
    wasm.vm.tick(ctx);
    assert_f64('neg(-3.5)=3.5', popf64(ctx^.ExecutionState.Operand_Stack), 3.5);

    code[0] := $9A;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_f64('neg(0.0)=0.0', popf64(ctx^.ExecutionState.Operand_Stack), 0.0);

    { NaN propagation }
    nanBits := $7FF8000000000000;
    code[0] := $9A;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_true('neg(NaN)=NaN', ((resultBits and $7FF0000000000000) = $7FF0000000000000) and ((resultBits and $000FFFFFFFFFFFFF) <> 0));

    test_end;
end;

end.
