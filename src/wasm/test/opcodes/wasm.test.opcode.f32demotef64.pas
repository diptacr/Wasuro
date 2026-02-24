unit wasm.test.opcode.f32demotef64;

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
    test_begin('opcode.f32.demote_f64');

    code[0] := $B6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_f32('demote(3.5)=3.5', popf32(ctx^.ExecutionState.Operand_Stack), 3.5);

    code[0] := $B6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_f32('demote(-1.0)=-1.0', popf32(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $B6;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_f32('demote(0.0)=0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    test_end;
end;

end.
