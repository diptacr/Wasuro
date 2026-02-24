unit wasm.test.opcode.i64truncf32s;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
    nanBits : TWASMUInt32;
begin
    test_begin('opcode.i64.trunc_f32_s');

    code[0] := $AE;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_i64('trunc(3.5)=3', popi64(ctx^.ExecutionState.Operand_Stack), 3);

    code[0] := $AE;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, -3.5);
    wasm.vm.tick(ctx);
    assert_i64('trunc(-3.5)=-3', popi64(ctx^.ExecutionState.Operand_Stack), -3);

    code[0] := $AE;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_i64('trunc(0.0)=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    { NaN traps }
    nanBits := $7FC00000;
    code[0] := $AE;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_bool('NaN traps', ctx^.ExecutionState.Running, false);

    { Overflow traps }
    code[0] := $AE;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0E19);
    wasm.vm.tick(ctx);
    assert_bool('overflow traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
