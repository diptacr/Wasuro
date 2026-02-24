unit wasm.test.opcode.f64eq;

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
begin
    test_begin('opcode.f64.eq');

    code[0] := $61;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0==1.0', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $61;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf64(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0!=2.0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $61;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -0.5);
    pushf64(ctx^.ExecutionState.Operand_Stack, -0.5);
    wasm.vm.tick(ctx);
    assert_i32('-0.5==-0.5', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { NaN==1.0 must be 0 }
    nanBits := $7FF8000000000000;
    code[0] := $61;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    pushf64(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('NaN==1.0 is 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { NaN==NaN must be 0 }
    code[0] := $61;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_i32('NaN==NaN is 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
