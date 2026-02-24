unit wasm.test.opcode.nop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.nop');

    { Test: nop advances IP by 1 and keeps running }
    code[0] := $01; { nop }
    ctx := make_test_context(@code[0], 1);
    wasm.vm.tick(ctx);
    assert_u32('ip advanced to 1', ctx^.ExecutionState.IP, 1);
    assert_bool('still running', ctx^.ExecutionState.Running, true);
    assert_u32('stack unchanged', ctx^.ExecutionState.Operand_Stack^.Top, 0);

    test_end;
end;

end.
