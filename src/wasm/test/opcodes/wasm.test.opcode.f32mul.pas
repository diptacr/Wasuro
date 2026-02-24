unit wasm.test.opcode.f32mul;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits, resultBits : TWASMUInt32;
    resultVal : TWASMFloat;
begin
    test_begin('opcode.f32.mul');

    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f32('2.0*3.0=6.0', popf32(ctx^.ExecutionState.Operand_Stack), 6.0);

    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -2.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f32('-2.0*3.0=-6.0', popf32(ctx^.ExecutionState.Operand_Stack), -6.0);

    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 5.0);
    wasm.vm.tick(ctx);
    assert_f32('0.0*5.0=0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    { NaN propagation }
    nanBits := $7FC00000;
    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('NaN*1.0=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    { Infinity: +Inf * 2 = +Inf }
    nanBits := $7F800000;
    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('+Inf*2=+Inf', resultBits = $7F800000);

    { Infinity: +Inf * 0 = NaN }
    nanBits := $7F800000;
    code[0] := $94;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('+Inf*0=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    test_end;
end;

end.
