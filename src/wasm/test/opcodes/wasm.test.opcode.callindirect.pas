unit wasm.test.opcode.callindirect;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.call_indirect');

    { Test: call_indirect traps (no table support) }
    code[0] := $11; { call_indirect }
    code[1] := $00; { type index 0 }
    code[2] := $00; { table index 0 }
    ctx := make_test_context(@code[0], 3);
    wasm.vm.tick(ctx);
    assert_true('call_indirect traps without table', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
