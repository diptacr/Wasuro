unit wasm.test.opcode.i32truncsatf32s;

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
    test_begin('opcode.i32.trunc_sat_f32_s');

    code[0] := $FC; code[1] := $00;

    { Normal truncation }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_i32('trunc_sat(3.5)=3', popi32(ctx^.ExecutionState.Operand_Stack), 3);

    { Negative }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, -3.5);
    wasm.vm.tick(ctx);
    assert_i32('trunc_sat(-3.5)=-3', popi32(ctx^.ExecutionState.Operand_Stack), -3);

    { Overflow high clamps to 2147483647 }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3000000000.0);
    wasm.vm.tick(ctx);
    assert_i32('overflow_high', popi32(ctx^.ExecutionState.Operand_Stack), 2147483647);

    { Overflow low clamps to -2147483648 }
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, -3000000000.0);
    wasm.vm.tick(ctx);
    assert_i32('overflow_low', popi32(ctx^.ExecutionState.Operand_Stack), -2147483648);

    { NaN returns 0 }
    nanBits := $7FC00000;
    ctx := make_test_context(@code[0], 2);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_i32('NaN=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
