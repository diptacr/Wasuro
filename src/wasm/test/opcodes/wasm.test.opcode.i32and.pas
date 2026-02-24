unit wasm.test.opcode.i32and;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.and');

    { Test: $FF and $0F = $0F }
    code[0] := $71;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FF));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($0F));
    wasm.vm.tick(ctx);
    assert_i32('$FF and $0F=$0F', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($0F));

    { Test: $FFFFFFFF and 0 = 0 }
    code[0] := $71;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFFFFFFF));
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('$FFFFFFFF and 0=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: $AAAAAAAA and $55555555 = 0 }
    code[0] := $71;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($AAAAAAAA));
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($55555555));
    wasm.vm.tick(ctx);
    assert_i32('$AA..$AA and $55..$55=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
