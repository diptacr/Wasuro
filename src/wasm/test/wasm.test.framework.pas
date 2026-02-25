unit wasm.test.framework;

interface

uses
    wasm.types.builtin, lmemorymanager, console,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context, wasm.types.heap, wasm.types.stack;

var
    TotalTests  : TWASMUInt32;
    PassedTests : TWASMUInt32;
    FailedTests : TWASMUInt32;

procedure reset_test_state;
procedure test_begin(name : TWASMPChar);
procedure assert_true(name : TWASMPChar; condition : TWASMBoolean);
procedure assert_i32(name : TWASMPChar; actual, expected : TWASMInt32);
procedure assert_i64(name : TWASMPChar; actual, expected : TWASMInt64);
procedure assert_f32(name : TWASMPChar; actual, expected : TWASMFloat);
procedure assert_f64(name : TWASMPChar; actual, expected : TWASMDouble);
procedure assert_u32(name : TWASMPChar; actual, expected : TWASMUInt32);
procedure assert_u64(name : TWASMPChar; actual, expected : TWASMUInt64);
procedure assert_bool(name : TWASMPChar; actual, expected : TWASMBoolean);
function  test_end : TWASMBoolean;

function  make_test_context(code : TWASMPUInt8; codeLen : TWASMUInt32) : PWASMProcessContext;
procedure setup_test_locals(ctx : PWASMProcessContext; count : TWASMUInt32; valType : TWasmValueType);
procedure setup_test_globals(ctx : PWASMProcessContext; count : TWASMUInt32; valType : TWasmValueType; mutable : TWASMBoolean);

implementation

procedure reset_test_state;
begin
    TotalTests := 0;
    PassedTests := 0;
    FailedTests := 0;
end;

procedure test_begin(name : TWASMPChar);
begin
    writestring('[TEST] ');
    writestringln(name);
end;

procedure pass(name : TWASMPChar);
begin
    Inc(TotalTests);
    Inc(PassedTests);
    writestring('  PASS: ');
    writestringln(name);
end;

procedure fail(name : TWASMPChar);
begin
    Inc(TotalTests);
    Inc(FailedTests);
    writestring('  FAIL: ');
    writestringln(name);
end;

procedure assert_true(name : TWASMPChar; condition : TWASMBoolean);
begin
    if condition then
        pass(name)
    else
        fail(name);
end;

procedure assert_i32(name : TWASMPChar; actual, expected : TWASMInt32);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
        writestring('    expected: ');
        writeintWND(expected, 0);
        writestring(' got: ');
        writeintlnWND(actual, 0);
    end;
end;

procedure assert_i64(name : TWASMPChar; actual, expected : TWASMInt64);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
        writestring('    expected: ');
        writeintWND(expected, 0);
        writestring(' got: ');
        writeintlnWND(actual, 0);
    end;
end;

procedure assert_f32(name : TWASMPChar; actual, expected : TWASMFloat);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
    end;
end;

procedure assert_f64(name : TWASMPChar; actual, expected : TWASMDouble);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
    end;
end;

procedure assert_u32(name : TWASMPChar; actual, expected : TWASMUInt32);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
        writestring('    expected: ');
        writeintWND(expected, 0);
        writestring(' got: ');
        writeintlnWND(actual, 0);
    end;
end;

procedure assert_u64(name : TWASMPChar; actual, expected : TWASMUInt64);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
        writestring('    expected: ');
        writeintWND(expected, 0);
        writestring(' got: ');
        writeintlnWND(actual, 0);
    end;
end;

procedure assert_bool(name : TWASMPChar; actual, expected : TWASMBoolean);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
        if expected then
            writestringln('    expected: true got: false')
        else
            writestringln('    expected: false got: true');
    end;
end;

function test_end : TWASMBoolean;
begin
    test_end := (FailedTests = 0);
end;

function make_test_context(code : TWASMPUInt8; codeLen : TWASMUInt32) : PWASMProcessContext;
var
    ctx : PWASMProcessContext;
begin
    ctx := PWASMProcessContext(kalloc(sizeof(TWASMProcessContext)));
    ctx^.ValidBinary := true;
    ctx^.Version := 1;
    ctx^.ExitCode := 0;

    { Execution state }
    ctx^.ExecutionState.Code := code;
    ctx^.ExecutionState.Limit := codeLen;
    ctx^.ExecutionState.IP := 0;
    ctx^.ExecutionState.Running := true;
    ctx^.ExecutionState.Memory := wasm.types.heap.new_heap();
    ctx^.ExecutionState.Operand_Stack := wasm.types.stack.newStack(1024);
    ctx^.ExecutionState.Control_Stack := wasm.types.stack.newStack(1024);

    { Empty globals }
    ctx^.ExecutionState.Globals := PWASMGlobals(kalloc(sizeof(TWASMGlobals)));
    ctx^.ExecutionState.Globals^.GlobalCount := 0;
    ctx^.ExecutionState.Globals^.Globals := nil;

    { Empty tables }
    ctx^.ExecutionState.Tables := PWASMTables(kalloc(sizeof(TWASMTables)));
    ctx^.ExecutionState.Tables^.TableCount := 0;
    ctx^.ExecutionState.Tables^.Tables := nil;

    { Empty data segments }
    ctx^.ExecutionState.DataSegments := PWASMDataSegments(kalloc(sizeof(TWASMDataSegments)));
    ctx^.ExecutionState.DataSegments^.SegmentCount := 0;
    ctx^.ExecutionState.DataSegments^.Segments := nil;

    { Empty element segments }
    ctx^.ExecutionState.ElementSegments := PWASMElementSegments(kalloc(sizeof(TWASMElementSegments)));
    ctx^.ExecutionState.ElementSegments^.SegmentCount := 0;
    ctx^.ExecutionState.ElementSegments^.Segments := nil;

    { Empty locals }
    ctx^.ExecutionState.Locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
    ctx^.ExecutionState.Locals^.LocalCount := 0;
    ctx^.ExecutionState.Locals^.TypeCount := 0;
    ctx^.ExecutionState.Locals^.Locals := nil;

    { Sections }
    ctx^.Sections.TypeSection := nil;
    ctx^.Sections.ImportSection := nil;
    ctx^.Sections.FunctionSection := nil;
    ctx^.Sections.ExportSection := nil;
    ctx^.Sections.CodeSection := nil;
    ctx^.Sections.MemorySection := nil;
    ctx^.Sections.StartIndex := -1;

    { Resolved imports }
    ctx^.ResolvedImports.Count := 0;
    ctx^.ResolvedImports.Imports := nil;

    { WASI hooks (all nil) }
    ctx^.WASIHooks.OnFdWrite := nil;
    ctx^.WASIHooks.OnFdRead := nil;
    ctx^.WASIHooks.OnFdClose := nil;
    ctx^.WASIHooks.OnFdSeek := nil;
    ctx^.WASIHooks.OnProcExit := nil;
    ctx^.WASIHooks.OnClockTimeGet := nil;
    ctx^.WASIHooks.OnClockResGet := nil;
    ctx^.WASIHooks.OnRandomGet := nil;
    ctx^.WASIHooks.OnArgsSizesGet := nil;
    ctx^.WASIHooks.OnArgsGet := nil;
    ctx^.WASIHooks.OnEnvironSizesGet := nil;
    ctx^.WASIHooks.OnEnvironGet := nil;

    { Host function registry (empty, lazy-init on first register) }
    ctx^.HostFuncRegistry.Count := 0;
    ctx^.HostFuncRegistry.Capacity := 0;
    ctx^.HostFuncRegistry.Entries := nil;

    make_test_context := ctx;
end;

procedure setup_test_locals(ctx : PWASMProcessContext; count : TWASMUInt32; valType : TWasmValueType);
var
    i : TWASMUInt32;
begin
    ctx^.ExecutionState.Locals^.LocalCount := count;
    ctx^.ExecutionState.Locals^.TypeCount := count;
    ctx^.ExecutionState.Locals^.Locals := PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * count));
    for i := 0 to count - 1 do begin
        ctx^.ExecutionState.Locals^.Locals[i].ValueType := valType;
        ctx^.ExecutionState.Locals^.Locals[i].i64Value := 0;
    end;
end;

procedure setup_test_globals(ctx : PWASMProcessContext; count : TWASMUInt32; valType : TWasmValueType; mutable : TWASMBoolean);
var
    i : TWASMUInt32;
begin
    ctx^.ExecutionState.Globals^.GlobalCount := count;
    ctx^.ExecutionState.Globals^.Globals := PWASMGlobalEntry(kalloc(sizeof(TWASMGlobalEntry) * count));
    for i := 0 to count - 1 do begin
        ctx^.ExecutionState.Globals^.Globals[i].ValueType := valType;
        ctx^.ExecutionState.Globals^.Globals[i].Mutable := mutable;
        ctx^.ExecutionState.Globals^.Globals[i].Value.ValueType := valType;
        ctx^.ExecutionState.Globals^.Globals[i].Value.i64Value := 0;
    end;
end;

end.
