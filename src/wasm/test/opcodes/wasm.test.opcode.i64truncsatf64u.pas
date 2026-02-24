unit wasm.test.opcode.i64truncsatf64u;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits : TWASMUInt64;
begin
    test_begin('opcode.i64.trunc_sat_f64_u');

    code[0] := $FC; code[1] := $07;

    { Normal truncation }
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_u64('trunc_sat(3.5)=3', TWASMUInt64(popi64(ctx^.ExecutionState.Operand_Stack)), 3);

    { Negative clamps to 0 }
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_u64('negative=0', TWASMUInt64(popi64(ctx^.ExecutionState.Operand_Stack)), 0);

    { NaN returns 0 }
    nanBits := $7FF8000000000000;
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_u64('NaN=0', TWASMUInt64(popi64(ctx^.ExecutionState.Operand_Stack)), 0);

    test_end;
end;

end.
