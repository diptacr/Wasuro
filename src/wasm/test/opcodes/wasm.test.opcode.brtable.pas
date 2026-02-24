unit wasm.test.opcode.brtable;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..31] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.br_table');

    { br_table with 2 labels + default, targeting nested blocks.
      Layout:
        block $40            ;; label 2
          block $40          ;; label 1
            block $40        ;; label 0
              i32.const <idx>
              br_table 2 0 1 2   ;; count=2, labels=[0,1], default=2
            end
            i32.const 10     ;; label 0 lands here
            return
          end
          i32.const 20       ;; label 1 lands here
          return
        end
        i32.const 30         ;; label 2 lands here
    }

    { Test 1: br_table index 0 selects label 0 }
    code[0]  := $02; { block (label 2) }
    code[1]  := $40;
    code[2]  := $02; { block (label 1) }
    code[3]  := $40;
    code[4]  := $02; { block (label 0) }
    code[5]  := $40;
    code[6]  := $41; { i32.const 0 }
    code[7]  := $00;
    code[8]  := $0E; { br_table }
    code[9]  := $02; { count = 2 labels }
    code[10] := $00; { label[0] = depth 0 }
    code[11] := $01; { label[1] = depth 1 }
    code[12] := $02; { default  = depth 2 }
    code[13] := $0B; { end (label 0) }
    code[14] := $41; { i32.const 10 }
    code[15] := $0A;
    code[16] := $0F; { return }
    code[17] := $0B; { end (label 1) }
    code[18] := $41; { i32.const 20 }
    code[19] := $14;
    code[20] := $0F; { return }
    code[21] := $0B; { end (label 2) }
    code[22] := $41; { i32.const 30 }
    code[23] := $1E;
    ctx := make_test_context(@code[0], 24);
    while wasm.vm.tick(ctx) do;
    assert_i32('br_table idx 0 selects label 0', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 10);

    { Test 2: br_table index 1 selects label 1 }
    code[7] := $01; { change index to 1 }
    ctx := make_test_context(@code[0], 24);
    while wasm.vm.tick(ctx) do;
    assert_i32('br_table idx 1 selects label 1', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 20);

    { Test 3: br_table index out of range selects default }
    code[7] := $05; { index 5, out of range -> default (depth 2) }
    ctx := make_test_context(@code[0], 24);
    while wasm.vm.tick(ctx) do;
    assert_i32('br_table default for out-of-range', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 30);

    test_end;
end;

end.
