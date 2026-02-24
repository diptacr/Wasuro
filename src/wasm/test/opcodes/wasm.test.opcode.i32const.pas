unit wasm.test.opcode.i32const;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..5] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32const');

    { Test: i32.const 42 (LEB128: $2A) }
    code[0] := $41; { i32.const }
    code[1] := $2A; { 42 }
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i32('const 42', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test: i32.const 0 }
    code[0] := $41;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i32('const 0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Test: i32.const 128 (LEB128: $80 $01) }
    code[0] := $41;
    code[1] := $80;
    code[2] := $01;
    ctx := make_test_context(@code[0], 3);
    wasm.vm.tick(ctx);
    assert_i32('const 128', popi32(ctx^.ExecutionState.Operand_Stack), 128);

    { Test: i32.const 127 }
    code[0] := $41;
    code[1] := $7F;
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i32('const 127', popi32(ctx^.ExecutionState.Operand_Stack), 127);

    test_end;
end;

end.
