unit wasm.test.opcode.f64ceil;

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
    test_begin('opcode.f64.ceil');

    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.5);
    wasm.vm.tick(ctx);
    assert_f64('ceil(1.5)=2.0', popf64(ctx^.ExecutionState.Operand_Stack), 2.0);

    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.5);
    wasm.vm.tick(ctx);
    assert_f64('ceil(-1.5)=-1.0', popf64(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f64('ceil(3.0)=3.0', popf64(ctx^.ExecutionState.Operand_Stack), 3.0);

    { NaN propagation }
    nanBits := $7FF8000000000000;
    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_true('ceil(NaN)=NaN', ((resultBits and $7FF0000000000000) = $7FF0000000000000) and ((resultBits and $000FFFFFFFFFFFFF) <> 0));

    { Infinity: ceil(+Inf) = +Inf }
    nanBits := $7FF0000000000000;
    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_true('ceil(+Inf)=+Inf', resultBits = $7FF0000000000000);

    { Infinity: ceil(-Inf) = -Inf }
    nanBits := TWASMUInt64($FFF0000000000000);
    code[0] := $9B;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_true('ceil(-Inf) sign', (resultBits and $8000000000000000) <> 0);
    assert_true('ceil(-Inf) inf', (resultBits and $7FFFFFFFFFFFFFFF) = $7FF0000000000000);

    test_end;
end;

end.
