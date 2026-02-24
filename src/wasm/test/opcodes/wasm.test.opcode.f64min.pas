unit wasm.test.opcode.f64min;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits : TWASMUInt64;
    negZero : TWASMUInt64;
    resultBits : TWASMUInt64;
    resultVal : TWASMDouble;
begin
    test_begin('opcode.f64.min');

    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_f64('min(1.0,2.0)=1.0', popf64(ctx^.ExecutionState.Operand_Stack), 1.0);

    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_f64('min(-1.0,1.0)=-1.0', popf64(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f64('min(3.0,3.0)=3.0', popf64(ctx^.ExecutionState.Operand_Stack), 3.0);

    { NaN propagation }
    nanBits := $7FF8000000000000;
    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_u64('min(NaN,1.0) is NaN', resultBits and $7FF8000000000000, $7FF8000000000000);

    { min(-0.0, +0.0) = -0.0 }
    negZero := $8000000000000000;
    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@negZero)^);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_u64('min(-0,+0)=-0', resultBits, $8000000000000000);

    { min(+0.0, -0.0) = -0.0 (commutative) }
    code[0] := $A4;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@negZero)^);
    wasm.vm.tick(ctx);
    resultVal := popf64(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt64(@resultVal)^;
    assert_u64('min(+0,-0)=-0', resultBits, $8000000000000000);

    test_end;
end;

end.
