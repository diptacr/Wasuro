unit wasm.test.opcode.i64clz;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64.clz');

    code[0] := $79;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('clz(0)=64', popi64(ctx^.ExecutionState.Operand_Stack), 64);

    code[0] := $79;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('clz(1)=63', popi64(ctx^.ExecutionState.Operand_Stack), 63);

    code[0] := $79;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, int64($8000000000000000));
    wasm.vm.tick(ctx);
    assert_i64('clz($8000000000000000)=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
