unit wasm.test.opcode.return;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.return');

    { Test: return with empty control stack stops execution }
    code[0] := $0F; { return }
    ctx := make_test_context(@code[0], 1);
    wasm.vm.tick(ctx);
    assert_true('empty control stack stops running', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
