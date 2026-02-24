unit wasm.test.opcode.i32popcnt;

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
    test_begin('opcode.i32.popcnt');

    { Test: popcnt(0) = 0 }
    code[0] := $69;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('popcnt(0)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: popcnt(1) = 1 }
    code[0] := $69;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('popcnt(1)=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: popcnt($FFFFFFFF) = 32 }
    code[0] := $69;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);  { = $FFFFFFFF }
    wasm.vm.tick(ctx);
    assert_i32('popcnt($FFFFFFFF)=32', popi32(ctx^.ExecutionState.Operand_Stack), 32);

    { Test: popcnt($55555555) = 16 }
    code[0] := $69;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($55555555));
    wasm.vm.tick(ctx);
    assert_i32('popcnt($55555555)=16', popi32(ctx^.ExecutionState.Operand_Stack), 16);

    test_end;
end;

end.
