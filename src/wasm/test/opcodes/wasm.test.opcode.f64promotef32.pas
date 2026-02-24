unit wasm.test.opcode.f64promotef32;

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
    test_begin('opcode.f64.promote_f32');

    code[0] := $BB;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_f64('promote(3.5)=3.5', popf64(ctx^.ExecutionState.Operand_Stack), 3.5);

    code[0] := $BB;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_f64('promote(-1.0)=-1.0', popf64(ctx^.ExecutionState.Operand_Stack), -1.0);

    code[0] := $BB;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_f64('promote(0.0)=0.0', popf64(ctx^.ExecutionState.Operand_Stack), 0.0);

    test_end;
end;

end.
