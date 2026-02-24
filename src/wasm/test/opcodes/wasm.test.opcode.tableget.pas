unit wasm.test.opcode.tableget;

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
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := $FFFFFFFF; { uninitialized }
end;

procedure run;
var
    code: array[0..3] of TWASMUInt8;
    ctx: PWASMProcessContext;
begin
    test_begin('opcode.table_get');

    { Test 1: table.get retrieves a funcref from table 0 }
    code[0] := $25;  { table.get }
    code[1] := $00;  { table index 0 }
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 4);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[2] := 42; { func index 42 at element 2 }
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 2); { element index }
    wasm.vm.tick(ctx);
    assert_u32('table.get returns funcref',
               wasm.types.stack.popfunc(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 2: table.get at index 0 }
    code[0] := $25;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 4);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 7;
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_u32('table.get index 0',
               wasm.types.stack.popfunc(ctx^.ExecutionState.Operand_Stack), 7);

    { Test 3: table.get out of bounds traps }
    code[0] := $25;
    code[1] := $00;
    ctx := make_test_context(@code[0], 2);
    setup_table(ctx, 2);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 5); { out of bounds }
    wasm.vm.tick(ctx);
    assert_true('table.get OOB traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
