unit wasm.test.opcode.tablecopy;

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
    { FC $0E, dst_table=0, src_table=0 }
    code : array[0..3] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.table.copy');

    code[0] := $FC; code[1] := $0E; code[2] := $00; code[3] := $00;

    { Non-overlapping copy within same table }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 8);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 10;
    ctx^.ExecutionState.Tables^.Tables[0].Elements[1] := 20;
    ctx^.ExecutionState.Tables^.Tables[0].Elements[2] := 30;
    pushi32(ctx^.ExecutionState.Operand_Stack, 4);   { d = 4 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    assert_u32('copy[4]=10', ctx^.ExecutionState.Tables^.Tables[0].Elements[4], 10);
    assert_u32('copy[5]=20', ctx^.ExecutionState.Tables^.Tables[0].Elements[5], 20);
    assert_u32('copy[6]=30', ctx^.ExecutionState.Tables^.Tables[0].Elements[6], 30);

    { Overlapping backward (d > s) }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 8);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 100;
    ctx^.ExecutionState.Tables^.Tables[0].Elements[1] := 200;
    ctx^.ExecutionState.Tables^.Tables[0].Elements[2] := 300;
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { d = 1 (d > s=0) }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    assert_u32('bwd[1]=100', ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 100);
    assert_u32('bwd[2]=200', ctx^.ExecutionState.Tables^.Tables[0].Elements[2], 200);
    assert_u32('bwd[3]=300', ctx^.ExecutionState.Tables^.Tables[0].Elements[3], 300);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    { Out of bounds traps }
    ctx := make_test_context(@code[0], 4);
    setup_table(ctx, 2);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 1;
    ctx^.ExecutionState.Tables^.Tables[0].Elements[1] := 2;
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);  { n=3 but table size=2 }
    wasm.vm.tick(ctx);
    assert_true('oob traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
