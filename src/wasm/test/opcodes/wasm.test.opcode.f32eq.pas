unit wasm.test.opcode.f32eq;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.f32.eq');

    code[0] := $5B;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0==1.0', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $5B;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0!=2.0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $5B;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -0.5);
    pushf32(ctx^.ExecutionState.Operand_Stack, -0.5);
    wasm.vm.tick(ctx);
    assert_i32('-0.5==-0.5', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
