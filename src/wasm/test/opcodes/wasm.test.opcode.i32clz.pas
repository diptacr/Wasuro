unit wasm.test.opcode.i32clz;

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
    test_begin('opcode.i32.clz');

    { Test: clz(0) = 32 }
    code[0] := $67;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('clz(0)=32', popi32(ctx^.ExecutionState.Operand_Stack), 32);

    { Test: clz(1) = 31 }
    code[0] := $67;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('clz(1)=31', popi32(ctx^.ExecutionState.Operand_Stack), 31);

    { Test: clz($80000000) = 0 }
    code[0] := $67;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($80000000));
    wasm.vm.tick(ctx);
    assert_i32('clz($80000000)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: clz($00010000) = 15 }
    code[0] := $67;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($00010000));
    wasm.vm.tick(ctx);
    assert_i32('clz($00010000)=15', popi32(ctx^.ExecutionState.Operand_Stack), 15);

    test_end;
end;

end.
