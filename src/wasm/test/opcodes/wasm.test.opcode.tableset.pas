unit wasm.test.opcode.tableset;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context, wasm.types.stack,
    wasm.vm, wasm.test.framework;

procedure setup_table(ctx: PWASMProcessContext; size: TWASMUInt32);
var
    i: TWASMUInt32;
begin
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].ElementType := $70; { funcref }
    ctx^.ExecutionState.Tables^.Tables[0].Size := size;
    ctx^.ExecutionState.Tables^.Tables[0].MaxSize := size;
    ctx^.ExecutionState.Tables^.Tables[0].HasMax := true;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(sizeof(TWASMUInt32) * size));
    for i := 0 to size - 1 do
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := $FFFFFFFF;
end;

procedure run;
var
    code: array[0..3] of TWASMUInt8;
    ctx: PWASMProcessContext;
begin
    test_begin('opcode.table_set');

    { Test 1: table.set stores a funcref into table 0 }
    code[0] := $26;  { table.set }
    code[1] := $00;  { table index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 4);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 1);  { element index }
    wasm.types.stack.pushfunc(ctx^.ExecutionState.Operand_Stack, 99); { funcref value }
    wasm.vm.tick(ctx);
    assert_u32('table.set stores funcref',
               ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 99);

    { Test 2: table.set at index 0 }
    code[0] := $26;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 4);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.types.stack.pushfunc(ctx^.ExecutionState.Operand_Stack, 5);
    wasm.vm.tick(ctx);
    assert_u32('table.set index 0',
               ctx^.ExecutionState.Tables^.Tables[0].Elements[0], 5);

    { Test 3: table.set out of bounds traps }
    code[0] := $26;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 2);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 10); { out of bounds }
    wasm.types.stack.pushfunc(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_true('table.set OOB traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
