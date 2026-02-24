unit wasm.test.opcode.i32reinterpretf32;

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
    test_begin('opcode.i32.reinterpret_f32');

    code[0] := $BC;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('reinterpret(1.0)', popi32(ctx^.ExecutionState.Operand_Stack), 1065353216);

    code[0] := $BC;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_i32('reinterpret(0.0)', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $BC;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -1.0);
    wasm.vm.tick(ctx);
    assert_i32('reinterpret(-1.0)', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($BF800000));

    test_end;
end;

end.
