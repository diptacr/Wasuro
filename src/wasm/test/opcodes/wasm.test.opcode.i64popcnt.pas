unit wasm.test.opcode.i64popcnt;

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
    test_begin('opcode.i64.popcnt');

    code[0] := $7B;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('popcnt(0)=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $7B;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('popcnt(1)=1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $7B;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i64('popcnt(-1)=64', popi64(ctx^.ExecutionState.Operand_Stack), 64);

    test_end;
end;

end.
