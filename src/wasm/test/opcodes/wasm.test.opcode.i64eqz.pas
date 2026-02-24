unit wasm.test.opcode.i64eqz;

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
    test_begin('opcode.i64.eqz');

    code[0] := $50;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('eqz(0)=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $50;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i32('eqz(1)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    code[0] := $50;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i32('eqz(-1)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
