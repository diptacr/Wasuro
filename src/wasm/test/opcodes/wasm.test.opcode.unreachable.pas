unit wasm.test.opcode.unreachable;

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
    test_begin('opcode.unreachable');

    { Test: unreachable traps (sets Running to false) }
    code[0] := $00; { unreachable }
    ctx := make_test_context(@code[0], 1);
    wasm.vm.tick(ctx);
    assert_bool('traps', ctx^.ExecutionState.Running, false);

    test_end;
end;

end.
