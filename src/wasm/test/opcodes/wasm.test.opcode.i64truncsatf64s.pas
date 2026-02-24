unit wasm.test.opcode.i64truncsatf64s;

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
    test_begin('opcode.i64.trunc_sat_f64_s');

    code[0] := $FC; code[1] := $06;

    { Normal truncation }
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_i64('trunc_sat(3.5)=3', popi64(ctx^.ExecutionState.Operand_Stack), 3);

    { Negative }
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, -3.5);
    wasm.vm.tick(ctx);
    assert_i64('trunc_sat(-3.5)=-3', popi64(ctx^.ExecutionState.Operand_Stack), -3);

    { NaN returns 0 }
    nanBits := $7FF8000000000000;
    ctx := make_test_context(@code[0], 2);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_i64('NaN=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
