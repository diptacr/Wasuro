unit wasm.test.opcode.i32xor;

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
    test_begin('opcode.i32.xor');

    { Test: $FF xor $FF = 0 }
    code[0] := $73;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FF));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FF));
    wasm.vm.tick(ctx);
    assert_i32('$FF xor $FF=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: $FF00 xor $00FF = $FFFF }
    code[0] := $73;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FF00));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($00FF));
    wasm.vm.tick(ctx);
    assert_i32('$FF00 xor $00FF=$FFFF', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($FFFF));

    { Test: 0 xor 0 = 0 }
    code[0] := $73;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('0 xor 0=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
