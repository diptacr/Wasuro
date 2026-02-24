unit wasm.test.opcode.i32shl;

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
    test_begin('opcode.i32.shl');

    { Test: 1 shl 4 = 16 }
    code[0] := $74;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 4);
    wasm.vm.tick(ctx);
    assert_i32('1 shl 4=16', popi32(ctx^.ExecutionState.Operand_Stack), 16);

    { Test: 1 shl 31 = $80000000 }
    code[0] := $74;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 31);
    wasm.vm.tick(ctx);
    assert_i32('1 shl 31=$80000000', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($80000000));

    { Test: 1 shl 0 = 1 }
    code[0] := $74;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('1 shl 0=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: shift wraps mod 32: 1 shl 32 = 1 }
    code[0] := $74;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 32);
    wasm.vm.tick(ctx);
    assert_i32('1 shl 32=1 (wrap)', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    test_end;
end;

end.
