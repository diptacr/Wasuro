unit wasm.test.opcode.f64copysign;

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
    test_begin('opcode.f64.copysign');

    code[0] := $A6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_f64('copysign(1.0,2.0)=1.0', popf64(ctx^.ExecutionState.Operand_Stack), 1.0);

    code[0] := $A6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, -2.0);
    wasm.vm.tick(ctx);
    assert_f64('copysign(1.0,-2.0)=-1.0', popf64(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $A6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_f64('copysign(-1.0,2.0)=1.0', popf64(ctx^.ExecutionState.Operand_Stack), 1.0);

    { NaN propagation }
    nanBits := $7FF8000000000000;
    code[0] := $A6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_true('copysign(NaN,1.0)=NaN', ((resultBits and $7FF0000000000000) = $7FF0000000000000) and ((resultBits and $000FFFFFFFFFFFFF) <> 0));

    test_end;
end;

end.
