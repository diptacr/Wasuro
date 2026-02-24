unit wasm.test.framework;

interface

uses
    types, lmemorymanager, console,
    wasm.types, wasm.types.heap, wasm.types.stack;

var
    TotalTests  : uint32;
    PassedTests : uint32;
    FailedTests : uint32;

procedure reset_test_state;
procedure test_begin(name : pchar);
procedure assert_true(name : pchar; condition : boolean);
procedure assert_i32(name : pchar; actual, expected : int32);
procedure assert_i64(name : pchar; actual, expected : int64);
procedure assert_f32(name : pchar; actual, expected : float);
procedure assert_f64(name : pchar; actual, expected : double);
procedure assert_u32(name : pchar; actual, expected : uint32);
procedure assert_u64(name : pchar; actual, expected : uint64);
procedure assert_bool(name : pchar; actual, expected : boolean);
function  test_end : boolean;

function  make_test_context(code : puint8; codeLen : uint32) : PWASMProcessContext;
procedure setup_test_locals(ctx : PWASMProcessContext; count : uint32; valType : TWasmValueType);
procedure setup_test_globals(ctx : PWASMProcessContext; count : uint32; valType : TWasmValueType; mutable : boolean);

implementation

procedure reset_test_state;
begin
    TotalTests := 0;
    PassedTests := 0;
    FailedTests := 0;
end;

procedure test_begin(name : pchar);
begin
    writestring('[TEST] ');
    writestringln(name);
end;

procedure pass(name : pchar);
begin
    Inc(TotalTests);
    Inc(PassedTests);
    writestring('  PASS: ');
    writestringln(name);
end;

procedure fail(name : pchar);
begin
    Inc(TotalTests);
    Inc(FailedTests);
    writestring('  FAIL: ');
    writestringln(name);
end;

procedure assert_true(name : pchar; condition : boolean);
begin
    if condition then
        pass(name)
    else
        fail(name);
end;

procedure assert_i32(name : pchar; actual, expected : int32);
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

procedure assert_i64(name : pchar; actual, expected : int64);
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

procedure assert_f32(name : pchar; actual, expected : float);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
    end;
end;

procedure assert_f64(name : pchar; actual, expected : double);
begin
    if actual = expected then
        pass(name)
    else begin
        fail(name);
    end;
end;

procedure assert_u32(name : pchar; actual, expected : uint32);
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

procedure assert_u64(name : pchar; actual, expected : uint64);
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

procedure assert_bool(name : pchar; actual, expected : boolean);
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

function test_end : boolean;
begin
    test_end := (FailedTests = 0);
end;

function make_test_context(code : puint8; codeLen : uint32) : PWASMProcessContext;
var
    ctx : PWASMProcessContext;
begin
    ctx := PWASMProcessContext(kalloc(sizeof(TWASMProcessContext)));
    ctx^.ValidBinary := true;
    ctx^.Version := 1;

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

    { Empty locals }
    ctx^.ExecutionState.Locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
    ctx^.ExecutionState.Locals^.LocalCount := 0;
    ctx^.ExecutionState.Locals^.TypeCount := 0;
    ctx^.ExecutionState.Locals^.Locals := nil;

    { Sections }
    ctx^.Sections.TypeSection := nil;
    ctx^.Sections.FunctionSection := nil;
    ctx^.Sections.ExportSection := nil;
    ctx^.Sections.CodeSection := nil;
    ctx^.Sections.MemorySection := nil;
    ctx^.Sections.StartIndex := -1;

    make_test_context := ctx;
end;

procedure setup_test_locals(ctx : PWASMProcessContext; count : uint32; valType : TWasmValueType);
var
    i : uint32;
begin
    ctx^.ExecutionState.Locals^.LocalCount := count;
    ctx^.ExecutionState.Locals^.TypeCount := count;
    ctx^.ExecutionState.Locals^.Locals := PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * count));
    for i := 0 to count - 1 do begin
        ctx^.ExecutionState.Locals^.Locals[i].ValueType := valType;
        ctx^.ExecutionState.Locals^.Locals[i].i64Value := 0;
    end;
end;

procedure setup_test_globals(ctx : PWASMProcessContext; count : uint32; valType : TWasmValueType; mutable : boolean);
var
    i : uint32;
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
