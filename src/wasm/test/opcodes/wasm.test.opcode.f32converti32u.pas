unit wasm.test.opcode.f32converti32u;

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
    test_begin('opcode.f32.convert_i32_u');

    code[0] := $B3;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 42);
    wasm.vm.tick(ctx);
    assert_f32('convert(42)=42.0', popf32(ctx^.ExecutionState.Operand_Stack), 42.0);

    code[0] := $B3;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_f32('convert(0)=0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    code[0] := $B3;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_f32('convert(1)=1.0', popf32(ctx^.ExecutionState.Operand_Stack), 1.0);

    test_end;
end;

end.
