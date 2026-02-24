unit wasm.test.opcode.f32ne;

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
    test_begin('opcode.f32.ne');

    code[0] := $5C;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0!=2.0', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $5C;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('1.0==1.0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { NaN!=1.0 must be 1 }
    nanBits := $7FC00000;
    code[0] := $5C;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_i32('NaN!=1.0 is 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { NaN!=NaN must be 1 }
    code[0] := $5C;
    ctx := make_test_context(@code[0], 1);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    pushf32(ctx^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
    wasm.vm.tick(ctx);
    assert_i32('NaN!=NaN is 1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
