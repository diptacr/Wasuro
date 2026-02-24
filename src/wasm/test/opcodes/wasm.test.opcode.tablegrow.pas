unit wasm.test.opcode.tablegrow;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.vm, wasm.test.framework, lmemorymanager;

procedure setup_table(ctx : PWASMProcessContext; size : TWASMUInt32; maxSize : TWASMUInt32; hasMax : TWASMBoolean);
var i : TWASMUInt32;
begin
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].Size := size;
    ctx^.ExecutionState.Tables^.Tables[0].MaxSize := maxSize;
    ctx^.ExecutionState.Tables^.Tables[0].HasMax := hasMax;
    ctx^.ExecutionState.Tables^.Tables[0].ElementType := $70;
    if size > 0 then begin
        ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(size * sizeof(TWASMUInt32)));
        for i := 0 to size - 1 do
            ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := i + 1;
    end else
        ctx^.ExecutionState.Tables^.Tables[0].Elements := nil;
end;

procedure run;
var
    { FC $0F, table_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    result_val : TWASMInt32;
begin
    test_begin('opcode.table.grow');

    code[0] := $FC; code[1] := $0F; code[2] := $00;

    { Grow table by 3, returns old size=2 }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 2, 10, true);
    pushi32(ctx^.ExecutionState.Operand_Stack, 42);  { val = 42 (init value) }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    result_val := popi32(ctx^.ExecutionState.Operand_Stack);
    assert_i32('old_size=2', result_val, 2);
    assert_u32('new_size=5', ctx^.ExecutionState.Tables^.Tables[0].Size, 5);
    { Old elements preserved }
    assert_u32('old[0]=1', ctx^.ExecutionState.Tables^.Tables[0].Elements[0], 1);
    assert_u32('old[1]=2', ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 2);
    { New elements initialized }
    assert_u32('new[2]=42', ctx^.ExecutionState.Tables^.Tables[0].Elements[2], 42);
    assert_u32('new[3]=42', ctx^.ExecutionState.Tables^.Tables[0].Elements[3], 42);
    assert_u32('new[4]=42', ctx^.ExecutionState.Tables^.Tables[0].Elements[4], 42);

    { Grow exceeds max → returns -1 }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 2, 3, true);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { val }
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);   { n = 5, would make 7 > max 3 }
    wasm.vm.tick(ctx);
    result_val := popi32(ctx^.ExecutionState.Operand_Stack);
    assert_i32('exceed_max=-1', result_val, -1);
    { Table unchanged }
    assert_u32('unchanged_size=2', ctx^.ExecutionState.Tables^.Tables[0].Size, 2);

    { Grow by 0 returns current size }
    ctx := make_test_context(@code[0], 3);
    setup_table(ctx, 4, 10, true);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    result_val := popi32(ctx^.ExecutionState.Operand_Stack);
    assert_i32('grow_0=4', result_val, 4);

    test_end;
end;

end.
