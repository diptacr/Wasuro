unit wasm.test.opcode.brif;

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
    test_begin('opcode.br_if');

    { Test 1: br_if with true condition exits block }
    { block $40  i32.const 42  i32.const 1  br_if 0  i32.const 99  end }
    code[0] := $02; { block }
    code[1] := $40;
    code[2] := $41; { i32.const 42 }
    code[3] := $2A;
    code[4] := $41; { i32.const 1 (condition: true) }
    code[5] := $01;
    code[6] := $0D; { br_if 0 }
    code[7] := $00;
    code[8] := $41; { i32.const 99 (unreachable) }
    code[9] := $63;
    code[10] := $0B; { end }
    ctx := make_test_context(@code[0], 11);
    while wasm.vm.tick(ctx) do;
    assert_i32('br_if true exits block', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 2: br_if with false condition continues }
    { block $40  i32.const 42  i32.const 0  br_if 0  drop  i32.const 7  end }
    code[0]  := $02; { block }
    code[1]  := $40;
    code[2]  := $41; { i32.const 42 }
    code[3]  := $2A;
    code[4]  := $41; { i32.const 0 (condition: false) }
    code[5]  := $00;
    code[6]  := $0D; { br_if 0 }
    code[7]  := $00;
    code[8]  := $1A; { drop (remove 42) }
    code[9]  := $41; { i32.const 7 }
    code[10] := $07;
    code[11] := $0B; { end }
    ctx := make_test_context(@code[0], 12);
    while wasm.vm.tick(ctx) do;
    assert_i32('br_if false continues execution', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 7);

    test_end;
end;

end.
