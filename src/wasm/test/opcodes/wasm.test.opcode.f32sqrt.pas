unit wasm.test.opcode.f32sqrt;

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
    test_begin('opcode.f32.sqrt');

    code[0] := $91;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 4.0);
    wasm.vm.tick(ctx);
    assert_f32('sqrt(4.0)=2.0', popf32(ctx^.ExecutionState.Operand_Stack), 2.0);

    code[0] := $91;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 9.0);
    wasm.vm.tick(ctx);
    assert_f32('sqrt(9.0)=3.0', popf32(ctx^.ExecutionState.Operand_Stack), 3.0);

    code[0] := $91;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_f32('sqrt(1.0)=1.0', popf32(ctx^.ExecutionState.Operand_Stack), 1.0);

    { NaN propagation }
    nanBits := $7FC00000;
    code[0] := $91;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('sqrt(NaN)=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    { Infinity: sqrt(+Inf) = +Inf }
    nanBits := $7F800000;
    code[0] := $91;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('sqrt(+Inf)=+Inf', resultBits = $7F800000);

    test_end;
end;

end.
