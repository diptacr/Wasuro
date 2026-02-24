unit wasm.test.opcode.i32truncsatf32u;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits : TWASMUInt32;
begin
    test_begin('opcode.i32.trunc_sat_f32_u');

    code[0] := $FC; code[1] := $01;

    { Normal truncation }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_u32('trunc_sat(3.5)=3', TWASMUInt32(popi32(ctx^.ExecutionState.Operand_Stack)), 3);

    { Large unsigned value clamps to 4294967295 }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, 5000000000.0);
    wasm.vm.tick(ctx);
    assert_u32('overflow_high', TWASMUInt32(popi32(ctx^.ExecutionState.Operand_Stack)), $FFFFFFFF);

    { Negative clamps to 0 }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_u32('negative=0', TWASMUInt32(popi32(ctx^.ExecutionState.Operand_Stack)), 0);

    { NaN returns 0 }
    nanBits := $7FC00000;
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_u32('NaN=0', TWASMUInt32(popi32(ctx^.ExecutionState.Operand_Stack)), 0);

    test_end;
end;

end.
