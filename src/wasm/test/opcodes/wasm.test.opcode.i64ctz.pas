unit wasm.test.opcode.i64ctz;

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
    test_begin('opcode.i64.ctz');

    code[0] := $7A;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('ctz(0)=64', popi64(ctx^.ExecutionState.Operand_Stack), 64);

    code[0] := $7A;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('ctz(1)=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $7A;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($8000000000000000));
    wasm.vm.tick(ctx);
    assert_i64('ctz($8000000000000000)=63', popi64(ctx^.ExecutionState.Operand_Stack), 63);

    test_end;
end;

end.
