unit wasm.test.opcode.tablefill;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.vm, wasm.test.framework, lmemorymanager;

procedure setup_table(ctx : PWASMProcessContext; size : TWASMUInt32);
var i : TWASMUInt32;
begin
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].Size := size;
    ctx^.ExecutionState.Tables^.Tables[0].MaxSize := size;
    ctx^.ExecutionState.Tables^.Tables[0].HasMax := true;
    ctx^.ExecutionState.Tables^.Tables[0].ElementType := $70;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(size * sizeof(TWASMUInt32)));
    for i := 0 to size - 1 do
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := 0;
end;

procedure run;
var
    { FC $11, table_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.table.fill');

    code[0] := $FC; code[1] := $11; code[2] := $00;

    { Fill 3 elements with value 77 at index 2 }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 8);
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);    { i = 2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 77);   { val = 77 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);    { n = 3 }
    wasm.vm.tick(ctx);
    assert_u32('table[2]=77', ctx^.ExecutionState.Tables^.Tables[0].Elements[2], 77);
    assert_u32('table[3]=77', ctx^.ExecutionState.Tables^.Tables[0].Elements[3], 77);
    assert_u32('table[4]=77', ctx^.ExecutionState.Tables^.Tables[0].Elements[4], 77);
    { Untouched elements }
    assert_u32('table[0]=0', ctx^.ExecutionState.Tables^.Tables[0].Elements[0], 0);
    assert_u32('table[1]=0', ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 0);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 99);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    { Out of bounds traps }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);    { i = 1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 55);   { val }
    pushi32(ctx^.ExecutionState.Operand_Stack, 4);    { n = 4, but only 2 slots left }
    wasm.vm.tick(ctx);
    assert_true('oob traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
