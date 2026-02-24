unit wasm.test.opcode.f64eq;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
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

    test_end;
end;

end.
