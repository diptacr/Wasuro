unit wasm.test.opcode.ifop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..20] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.if');

    { Test 1: if with true condition (no else) }
    { i32.const 1  if $40  i32.const 42  end }
    code[0] := $41; { i32.const 1 }
    code[1] := $01;
    code[2] := $04; { if }
    code[3] := $40; { blocktype $40 }
    code[4] := $41; { i32.const 42 }
    code[5] := $2A;
    code[6] := $0B; { end }
    ctx := make_test_context(@code[0], 7);
    while wasm.vm.tick(ctx) do;
    assert_i32('if true executes body', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 2: if with false condition (no else) - body skipped }
    { i32.const 0  if $40  i32.const 99  end  i32.const 7 }
    code[0] := $41; { i32.const 0 }
    code[1] := $00;
    code[2] := $04; { if }
    code[3] := $40;
    code[4] := $41; { i32.const 99 (should be skipped) }
    code[5] := $63;
    code[6] := $0B; { end }
    code[7] := $41; { i32.const 7 }
    code[8] := $07;
    ctx := make_test_context(@code[0], 9);
    while wasm.vm.tick(ctx) do;
    assert_i32('if false skips body', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 7);

    { Test 3: if-else with true condition (takes if branch) }
    { i32.const 1  if $40  i32.const 10  else  i32.const 20  end }
    code[0] := $41; { i32.const 1 }
    code[1] := $01;
    code[2] := $04; { if }
    code[3] := $40;
    code[4] := $41; { i32.const 10 }
    code[5] := $0A;
    code[6] := $05; { else }
    code[7] := $41; { i32.const 20 }
    code[8] := $14;
    code[9] := $0B; { end }
    ctx := make_test_context(@code[0], 10);
    while wasm.vm.tick(ctx) do;
    assert_i32('if-else true takes if branch', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 10);

    { Test 4: if-else with false condition (takes else branch) }
    { i32.const 0  if $40  i32.const 10  else  i32.const 20  end }
    code[0] := $41; { i32.const 0 }
    code[1] := $00;
    code[2] := $04; { if }
    code[3] := $40;
    code[4] := $41; { i32.const 10 }
    code[5] := $0A;
    code[6] := $05; { else }
    code[7] := $41; { i32.const 20 }
    code[8] := $14;
    code[9] := $0B; { end }
    ctx := make_test_context(@code[0], 10);
    while wasm.vm.tick(ctx) do;
    assert_i32('if-else false takes else branch', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 20);

    { Test 5: nested if }
    { i32.const 1  if $40  i32.const 1  if $40  i32.const 55  end  end }
    code[0]  := $41; { i32.const 1 }
    code[1]  := $01;
    code[2]  := $04; { outer if }
    code[3]  := $40;
    code[4]  := $41; { i32.const 1 }
    code[5]  := $01;
    code[6]  := $04; { inner if }
    code[7]  := $40;
    code[8]  := $41; { i32.const 55 }
    code[9]  := $37;
    code[10] := $0B; { end inner }
    code[11] := $0B; { end outer }
    ctx := make_test_context(@code[0], 12);
    while wasm.vm.tick(ctx) do;
    assert_i32('nested if result', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 55);

    test_end;
end;

end.
