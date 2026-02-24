unit wasm.test.opcode.i64const;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..10] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64const');

    { Test: i64.const 42 }
    code[0] := $42; { i64.const }
    code[1] := $2A; { 42 }
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i64('const 42', popi64(ctx^.ExecutionState.Operand_Stack), 42);

    { Test: i64.const 0 }
    code[0] := $42;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i64('const 0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: i64.const 128 (LEB128: $80 $01) }
    code[0] := $42;
    code[1] := $80;
    code[2] := $01;
    ctx := make_test_context(@code[0], 3);
    wasm.vm.tick(ctx);
    assert_i64('const 128', popi64(ctx^.ExecutionState.Operand_Stack), 128);

    test_end;
end;

end.
