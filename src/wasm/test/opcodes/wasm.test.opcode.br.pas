unit wasm.test.opcode.br;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.enums, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..20] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.br');

    { Test 1: br 0 exits innermost block }
    { block $40  i32.const 42  br 0  i32.const 99  end }
    code[0] := $02; { block }
    code[1] := $40;
    code[2] := $41; { i32.const 42 }
    code[3] := $2A;
    code[4] := $0C; { br 0 }
    code[5] := $00;
    code[6] := $41; { i32.const 99 (unreachable) }
    code[7] := $63;
    code[8] := $0B; { end }
    ctx := make_test_context(@code[0], 9);
    while wasm.vm.tick(ctx) do;
    assert_i32('br 0 exits block with value', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 2: br 1 exits outer block from nested block }
    { block $40  block $40  i32.const 77  br 1  end  i32.const 99  end }
    code[0]  := $02; { outer block }
    code[1]  := $40;
    code[2]  := $02; { inner block }
    code[3]  := $40;
    code[4]  := $41; { i32.const 77 }
    code[5]  := $4D;
    code[6]  := $0C; { br 1 (exit outer) }
    code[7]  := $01;
    code[8]  := $0B; { end inner }
    code[9]  := $41; { i32.const 99 (unreachable) }
    code[10] := $63;
    code[11] := $0B; { end outer }
    ctx := make_test_context(@code[0], 12);
    while wasm.vm.tick(ctx) do;
    assert_i32('br 1 exits outer block', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 77);

    { Test 3: br 0 in loop re-enters loop (tested via local counter) }
    { i32.const 2  local.set 0
      loop $40
        local.get 0  i32.const 1  i32.sub  local.tee 0
        br_if 0
      end
      local.get 0 }
    code[0]  := $41; { i32.const 2 }
    code[1]  := $02;
    code[2]  := $21; { local.set 0 }
    code[3]  := $00;
    code[4]  := $03; { loop }
    code[5]  := $40;
    code[6]  := $20; { local.get 0 }
    code[7]  := $00;
    code[8]  := $41; { i32.const 1 }
    code[9]  := $01;
    code[10] := $6B; { i32.sub }
    code[11] := $22; { local.tee 0 }
    code[12] := $00;
    code[13] := $0D; { br_if 0 }
    code[14] := $00;
    code[15] := $0B; { end loop }
    code[16] := $20; { local.get 0 }
    code[17] := $00;
    ctx := make_test_context(@code[0], 18);
    setup_test_locals(ctx, 1, vti32);
    while wasm.vm.tick(ctx) do;
    assert_i32('br loop countdown result', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
