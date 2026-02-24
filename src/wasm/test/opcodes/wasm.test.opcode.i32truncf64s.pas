unit wasm.test.opcode.i32truncf64s;

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
    test_begin('opcode.i32.trunc_f64_s');

    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3.5);
    wasm.vm.tick(ctx);
    assert_i32('trunc(3.5)=3', popi32(ctx^.ExecutionState.Operand_Stack), 3);

    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -3.5);
    wasm.vm.tick(ctx);
    assert_i32('trunc(-3.5)=-3', popi32(ctx^.ExecutionState.Operand_Stack), -3);

    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 0.0);
    wasm.vm.tick(ctx);
    assert_i32('trunc(0.0)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { NaN traps }
    nanBits := $7FF8000000000000;
    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_bool('NaN traps', ctx^.ExecutionState.Running, false);

    { Overflow high traps }
    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, 3000000000.0);
    wasm.vm.tick(ctx);
    assert_bool('overflow high traps', ctx^.ExecutionState.Running, false);

    { Overflow low traps }
    code[0] := $AA;
    ctx := make_test_context(@code[0], 1);
    pushf64(ctx^.ExecutionState.Operand_Stack, -3000000000.0);
    wasm.vm.tick(ctx);
    assert_bool('overflow low traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
