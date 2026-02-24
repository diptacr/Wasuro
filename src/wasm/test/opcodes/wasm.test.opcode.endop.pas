unit wasm.test.opcode.endop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..7] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.end');

    { Test 1: end with empty control stack stops execution }
    code[0] := $0B; { end }
    ctx := make_test_context(@code[0], 1);
    wasm.vm.tick(ctx);
    assert_true('end stops at top level', ctx^.ExecutionState.Running = false);

    { Test 2: end pops block frame and continues }
    { block $40  i32.const 5  end  i32.const 3  i32.add }
    code[0] := $02; { block }
    code[1] := $40;
    code[2] := $41; { i32.const 5 }
    code[3] := $05;
    code[4] := $0B; { end block }
    code[5] := $41; { i32.const 3 }
    code[6] := $03;
    code[7] := $6A; { i32.add }
    ctx := make_test_context(@code[0], 8);
    while wasm.vm.tick(ctx) do;
    assert_i32('end continues after block', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 8);

    test_end;
end;

end.
