unit wasm.test.opcode.f32reinterpreti32;

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
    test_begin('opcode.f32.reinterpret_i32');

    code[0] := $BE;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($3F800000));
    wasm.vm.tick(ctx);
    assert_f32('reinterpret($3F800000)=1.0', popf32(ctx^.ExecutionState.Operand_Stack), 1.0);

    code[0] := $BE;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_f32('reinterpret(0)=0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    code[0] := $BE;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($40000000));
    wasm.vm.tick(ctx);
    assert_f32('reinterpret($40000000)=2.0', popf32(ctx^.ExecutionState.Operand_Stack), 2.0);

    test_end;
end;

end.
