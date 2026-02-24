unit wasm.test.opcode.tableinit;

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
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := $FFFFFFFF;
end;

procedure setup_elem_segment(ctx : PWASMProcessContext; count : TWASMUInt32);
var i : TWASMUInt32;
begin
    ctx^.ExecutionState.ElementSegments^.SegmentCount := 1;
    ctx^.ExecutionState.ElementSegments^.Segments := PWASMElementSegment(kalloc(sizeof(TWASMElementSegment)));
    ctx^.ExecutionState.ElementSegments^.Segments[0].FuncCount := count;
    ctx^.ExecutionState.ElementSegments^.Segments[0].FuncIndices := TWASMPUInt32(kalloc(count * sizeof(TWASMUInt32)));
    ctx^.ExecutionState.ElementSegments^.Segments[0].Dropped := false;
    ctx^.ExecutionState.ElementSegments^.Segments[0].TableIndex := 0;
    ctx^.ExecutionState.ElementSegments^.Segments[0].Offset := 0;
    for i := 0 to count - 1 do
        ctx^.ExecutionState.ElementSegments^.Segments[0].FuncIndices[i] := 100 + i;
end;

procedure run;
var
    { FC $0C, elem_idx=0, table_idx=0 }
    code : array[0..3] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.table.init');

    code[0] := $FC; code[1] := $0C; code[2] := $00; code[3] := $00;

    { Copy 3 elements from elem segment to table at offset 1 }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 8);
    setup_elem_segment(ctx, 4);  { funcIndices = [100, 101, 102, 103] }
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { d = 1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    assert_u32('table[1]=100', ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 100);
    assert_u32('table[2]=101', ctx^.ExecutionState.Tables^.Tables[0].Elements[2], 101);
    assert_u32('table[3]=102', ctx^.ExecutionState.Tables^.Tables[0].Elements[3], 102);
    { table[0] should be untouched }
    assert_u32('table[0]=uninit', ctx^.ExecutionState.Tables^.Tables[0].Elements[0], $FFFFFFFF);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 4);
    setup_elem_segment(ctx, 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    { Dropped segment traps }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 4);
    setup_elem_segment(ctx, 4);
    ctx^.ExecutionState.ElementSegments^.Segments[0].Dropped := true;
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_true('dropped traps', not ctx^.ExecutionState.Running);

    { Out of bounds dest traps }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 2);
    setup_elem_segment(ctx, 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);  { table only has 2 slots }
    wasm.vm.tick(ctx);
    assert_true('oob_dest traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
