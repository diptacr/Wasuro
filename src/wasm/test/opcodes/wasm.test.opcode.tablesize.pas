unit wasm.test.opcode.tablesize;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.vm, wasm.test.framework, lmemorymanager;

procedure run;
var
    { FC $10, table_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    result_val : TWASMInt32;
begin
    test_begin('opcode.table.size');

    code[0] := $FC; code[1] := $10; code[2] := $00;

    { Size of table with 5 elements }
    ctx := make_test_context(@code[0], 3);
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].Size := 5;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(5 * sizeof(TWASMUInt32)));
    wasm.vm.tick(ctx);
    result_val := popi32(ctx^.ExecutionState.Operand_Stack);
    assert_i32('size=5', result_val, 5);

    { Size of empty table }
    ctx := make_test_context(@code[0], 3);
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].Size := 0;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := nil;
    wasm.vm.tick(ctx);
    result_val := popi32(ctx^.ExecutionState.Operand_Stack);
    assert_i32('size=0', result_val, 0);

    { Invalid table index traps }
    ctx := make_test_context(@code[0], 3);
    { Tables^.TableCount = 0 (default) }
    wasm.vm.tick(ctx);
    assert_true('invalid_idx traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
