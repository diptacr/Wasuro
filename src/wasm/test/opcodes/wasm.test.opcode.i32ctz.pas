unit wasm.test.opcode.i32ctz;

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
    test_begin('opcode.i32.ctz');

    { Test: ctz(0) = 32 }
    code[0] := $68;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('ctz(0)=32', popi32(ctx^.ExecutionState.Operand_Stack), 32);

    { Test: ctz(1) = 0 }
    code[0] := $68;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('ctz(1)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: ctz($80000000) = 31 }
    code[0] := $68;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($80000000));
    wasm.vm.tick(ctx);
    assert_i32('ctz($80000000)=31', popi32(ctx^.ExecutionState.Operand_Stack), 31);

    { Test: ctz($00010000) = 16 }
    code[0] := $68;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, int32($00010000));
    wasm.vm.tick(ctx);
    assert_i32('ctz($00010000)=16', popi32(ctx^.ExecutionState.Operand_Stack), 16);

    test_end;
end;

end.
