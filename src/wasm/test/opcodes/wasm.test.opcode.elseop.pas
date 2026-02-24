unit wasm.test.opcode.elseop;

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
    test_begin('opcode.else');

    { Test 1: else skips else-body when if-true path taken }
    { i32.const 1  if $40  i32.const 10  else  i32.const 20  end }
    { When condition is true the if-true body runs and else skips to past end }
    code[0] := $41; { i32.const 1 }
    code[1] := $01;
    code[2] := $04; { if }
    code[3] := $40; { blocktype empty }
    code[4] := $41; { i32.const 10 }
    code[5] := $0A;
    code[6] := $05; { else }
    code[7] := $41; { i32.const 20 }
    code[8] := $14;
    code[9] := $0B; { end }
    ctx := make_test_context(@code[0], 10);
    while wasm.vm.tick(ctx) do;
    assert_i32('true path skips else body', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 10);

    { Test 2: else-body executes when condition is false }
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
    assert_i32('false path executes else body', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 20);

    { Test 3: else skips nested block in else-body }
    { i32.const 1  if $40  i32.const 5  else  block $40  i32.const 99  end  end }
    code[0]  := $41; { i32.const 1 }
    code[1]  := $01;
    code[2]  := $04; { if }
    code[3]  := $40;
    code[4]  := $41; { i32.const 5 }
    code[5]  := $05;
    code[6]  := $05; { else }
    code[7]  := $02; { block }
    code[8]  := $40;
    code[9]  := $41; { i32.const 99 }
    code[10] := $63;
    code[11] := $0B; { end block }
    code[12] := $0B; { end if }
    ctx := make_test_context(@code[0], 13);
    while wasm.vm.tick(ctx) do;
    assert_i32('else skips nested block', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 5);

    { Test 4: execution continues after end when else is skipped }
    { i32.const 1  if $40  i32.const 3  else  i32.const 4  end  i32.const 7 }
    code[0]  := $41; { i32.const 1 }
    code[1]  := $01;
    code[2]  := $04; { if }
    code[3]  := $40;
    code[4]  := $41; { i32.const 3 }
    code[5]  := $03;
    code[6]  := $05; { else }
    code[7]  := $41; { i32.const 4 }
    code[8]  := $04;
    code[9]  := $0B; { end }
    code[10] := $41; { i32.const 7 }
    code[11] := $07;
    ctx := make_test_context(@code[0], 12);
    while wasm.vm.tick(ctx) do;
    assert_i32('continues after else skip', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 7);

    test_end;
end;

end.
