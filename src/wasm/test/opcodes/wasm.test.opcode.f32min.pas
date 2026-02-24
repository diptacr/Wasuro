unit wasm.test.opcode.f32min;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits : TWASMUInt32;
    negZero : TWASMUInt32;
    resultBits : TWASMUInt32;
    resultVal : TWASMFloat;
begin
    test_begin('opcode.f32.min');

    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_f32('min(1.0,2.0)=1.0', popf32(ctx^.ExecutionState.Operand_Stack), 1.0);

    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_f32('min(-1.0,1.0)=-1.0', popf32(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f32('min(3.0,3.0)=3.0', popf32(ctx^.ExecutionState.Operand_Stack), 3.0);

    { NaN propagation }
    nanBits := $7FC00000;
    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_u32('min(NaN,1.0) is NaN', resultBits and $7FC00000, $7FC00000);

    { min(-0.0, +0.0) = -0.0 }
    negZero := $80000000;
    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@negZero)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_u32('min(-0,+0)=-0', resultBits, $80000000);

    { min(+0.0, -0.0) = -0.0 (commutative) }
    code[0] := $96;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@negZero)^);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_u32('min(+0,-0)=-0', resultBits, $80000000);

    test_end;
end;

end.
