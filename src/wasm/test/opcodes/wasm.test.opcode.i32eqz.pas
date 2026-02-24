unit wasm.test.opcode.i32eqz;

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
    test_begin('opcode.i32.eqz');

    { Test: 0 == 0 -> 1 }
    code[0] := $45;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('eqz(0)=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: 1 != 0 -> 0 }
    code[0] := $45;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('eqz(1)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: -1 != 0 -> 0 }
    code[0] := $45;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('eqz(-1)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
