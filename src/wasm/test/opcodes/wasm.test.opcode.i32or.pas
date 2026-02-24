unit wasm.test.opcode.i32or;

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
    test_begin('opcode.i32.or');

    { Test: $FF00 or $00FF = $FFFF }
    code[0] := $72;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FF00));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($00FF));
    wasm.vm.tick(ctx);
    assert_i32('$FF00 or $00FF=$FFFF', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($FFFF));

    { Test: 0 or 0 = 0 }
    code[0] := $72;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('0 or 0=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: $AAAAAAAA or $55555555 = $FFFFFFFF }
    code[0] := $72;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($AAAAAAAA));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($55555555));
    wasm.vm.tick(ctx);
    assert_i32('$AA..$AA or $55..$55=$FF..$FF', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($FFFFFFFF));

    test_end;
end;

end.
