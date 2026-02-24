unit wasm.test.opcode.block;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..15] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.block');

    { Test 1: simple empty block falls through }
    { block $40 ... nop ... end }
    code[0] := $02; { block }
    code[1] := $40; { blocktype $40 }
    code[2] := $01; { nop }
    code[3] := $0B; { end }
    ctx := make_test_context(@code[0], 4);
    while wasm.vm.tick(ctx) do;
    assert_true('empty block completes', ctx^.ExecutionState.Running = false);
    assert_u32('empty block IP at end', ctx^.ExecutionState.IP, 4);

    { Test 2: block with value on stack }
    { block $40 i32.const 42 end }
    code[0] := $02; { block }
    code[1] := $40; { blocktype $40 }
    code[2] := $41; { i32.const }
    code[3] := $2A; { 42 }
    code[4] := $0B; { end }
    ctx := make_test_context(@code[0], 5);
    while wasm.vm.tick(ctx) do;
    assert_i32('block preserves stack value', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 3: nested blocks }
    { block $40 block $40 i32.const 7 end i32.const 3 i32.add end }
    code[0]  := $02; { outer block }
    code[1]  := $40; { blocktype $40 }
    code[2]  := $02; { inner block }
    code[3]  := $40;
    code[4]  := $41; { i32.const 7 }
    code[5]  := $07;
    code[6]  := $0B; { end inner }
    code[7]  := $41; { i32.const 3 }
    code[8]  := $03;
    code[9]  := $6A; { i32.add }
    code[10] := $0B; { end outer }
    ctx := make_test_context(@code[0], 11);
    while wasm.vm.tick(ctx) do;
    assert_i32('nested blocks result', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 10);

    test_end;
end;

end.
