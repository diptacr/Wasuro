unit wasm.test.opcode.f32add;

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
    test_begin('opcode.f32.add');

    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_f32('1.0+2.0=3.0', popf32(ctx^.ExecutionState.Operand_Stack), 3.0);

    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_f32('-1.0+1.0=0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.5);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.25);
    wasm.vm.tick(ctx);
    assert_f32('0.5+0.25=0.75', popf32(ctx^.ExecutionState.Operand_Stack), 0.75);

    { NaN propagation }
    nanBits := $7FC00000;
    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('NaN+1.0=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    { Infinity: +Inf + 1 = +Inf }
    nanBits := $7F800000; { +Inf }
    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('+Inf+1=+Inf', resultBits = $7F800000);

    { Infinity: +Inf + (-Inf) = NaN }
    nanBits := $7F800000;
    code[0] := $92;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    nanBits := $FF800000; { -Inf }
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('+Inf+(-Inf)=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    test_end;
end;

end.
