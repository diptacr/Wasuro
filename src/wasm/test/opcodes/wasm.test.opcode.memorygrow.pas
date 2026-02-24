unit wasm.test.opcode.memorygrow;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..1] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.memory.grow');

    { Test: grow by 2 pages, returns old size (1) }
    code[0] := $40; { memory.grow }
    code[1] := $00; { memory index }
    ctx := make_test_context(@code[0], 2);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2); { pages to grow }
    wasm.vm.tick(ctx);
    assert_i32('grow returns old size=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);
    assert_u32('new page count=3', ctx^.ExecutionState.Memory^.PageCount, 3);

    { Test: grow by 0 pages returns current size }
    code[0] := $40;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('grow 0 returns size=1', popi32(ctx^.ExecutionState.Operand_Stack), 1);
    assert_u32('page count unchanged=1', ctx^.ExecutionState.Memory^.PageCount, 1);

    test_end;
end;

end.
