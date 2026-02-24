unit wasm.test.opcode.f32trunc;

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
    test_begin('opcode.f32.trunc');

    code[0] := $8F;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.7);
    wasm.vm.tick(ctx);
    assert_f32('trunc(2.7)=2.0', popf32(ctx^.ExecutionState.Operand_Stack), 2.0);

    code[0] := $8F;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -2.7);
    wasm.vm.tick(ctx);
    assert_f32('trunc(-2.7)=-2.0', popf32(ctx^.ExecutionState.Operand_Stack), -2.0);

    code[0] := $8F;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.0);
    wasm.vm.tick(ctx);
    assert_f32('trunc(3.0)=3.0', popf32(ctx^.ExecutionState.Operand_Stack), 3.0);

    { NaN propagation }
    nanBits := $7FC00000;
    code[0] := $8F;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    resultVal := popf32(ctx^.ExecutionState.Operand_Stack);
    resultBits := TWASMPUInt32(@resultVal)^;
    assert_true('trunc(NaN)=NaN', ((resultBits and $7F800000) = $7F800000) and ((resultBits and $007FFFFF) <> 0));

    test_end;
end;

end.
