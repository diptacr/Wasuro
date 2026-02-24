unit wasm.test.opcode.memorysize;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.memory.size');

    { Test: initial heap has 1 page }
    code[0] := $3F; { memory.size }
    code[1] := $00; { memory index }
    ctx := make_test_context(@code[0], 2);
    wasm.vm.tick(ctx);
    assert_i32('initial size=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);

    { Test: after expand, size = 2 }
    code[0] := $3F;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    expand_heap(ctx^.ExecutionState.Memory);
    wasm.vm.tick(ctx);
    assert_i32('after expand size=2', popi32(ctx^.ExecutionState.Operand_Stack), 2);

    { Test: after two expands, size = 3 }
    code[0] := $3F;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    expand_heap(ctx^.ExecutionState.Memory);
    expand_heap(ctx^.ExecutionState.Memory);
    wasm.vm.tick(ctx);
    assert_i32('after 2 expands size=3', popi32(ctx^.ExecutionState.Operand_Stack), 3);

    test_end;
end;

end.
