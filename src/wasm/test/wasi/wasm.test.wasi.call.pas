unit wasm.test.wasi.call;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack,
    wasm.wasi.registry,
    wasm.vm,
    wasm.test.framework;

{ Mock host function: pushes 99 onto the stack }
procedure mock_push99(Context : PWASMProcessContext);
begin
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 99);
end;

{ Mock host function: pops i32, multiplies by 2, pushes result }
procedure mock_times2(Context : PWASMProcessContext);
var val : TWASMInt32;
begin
    val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, val * 2);
end;

procedure setup_import_section(ctx: PWASMProcessContext;
                               numImports: TWASMUInt32);
begin
    ctx^.Sections.ImportSection := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    ctx^.Sections.ImportSection^.ImportCount := numImports;
    ctx^.Sections.ImportSection^.Entries :=
        PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * numImports));
end;

procedure set_func_import(sec: PWASMImportSection; idx: TWASMUInt32;
                          modName, fieldName: TWASMPChar;
                          typeIdx: TWASMUInt32);
begin
    sec^.Entries[idx].ModuleName := modName;
    sec^.Entries[idx].ModuleNameLength := 0; { not needed for dispatch }
    sec^.Entries[idx].FieldName := fieldName;
    sec^.Entries[idx].FieldNameLength := 0;
    sec^.Entries[idx].Desc.Kind := $00;
    sec^.Entries[idx].Desc.TypeIndex := typeIdx;
end;

procedure run;
var
    flatCode : array[0..31] of TWASMUInt8;
    ctx      : PWASMProcessContext;
    types    : array[0..1] of TWASMType;
    returns  : array[0..0] of TWASMParam;
    params   : array[0..0] of TWASMParam;
begin
    test_begin('wasi.call (import dispatch)');

    { ------------------------------------------------------------------ }
    { Test 1: call import func 0 (push99), module has 1 import + 0 local }
    {   Import 0 = test:push99                                           }
    {   Code: call 0  end  (3 bytes)                                     }
    { ------------------------------------------------------------------ }
    flatCode[0] := $10; { call }
    flatCode[1] := $00; { func index 0 = import 0 }
    flatCode[2] := $0B; { end }

    ctx := make_test_context(@flatCode[0], 3);

    { Import section: 1 function import }
    setup_import_section(ctx, 1);
    set_func_import(ctx^.Sections.ImportSection, 0, 'test', 'push99', 0);

    { Type section: () -> i32 }
    types[0]._type       := $60;
    types[0].ParamCount  := 0;
    types[0].ParamTypes  := nil;
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.TypeSection^.TypeCount := 1;
    ctx^.Sections.TypeSection^.Types := @types[0];

    { No local functions }
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 0;
    ctx^.Sections.FunctionSection^.Functions := nil;

    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 0;
    ctx^.Sections.CodeSection^.Entries := nil;

    { Register and resolve imports }
    wasm.wasi.registry.register_host_func(ctx, 'test', 'push99', @mock_push99);
    wasm.wasi.registry.resolve_imports(ctx);

    { Run }
    ctx^.ExecutionState.IP := 0;
    while wasm.vm.tick(ctx) do;

    assert_i32('call import push99 => 99',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 99);

    { ------------------------------------------------------------------ }
    { Test 2: call import that takes params (times2)                     }
    {   Import 0 = test:times2                                           }
    {   Code: i32.const 21  call 0  end                                  }
    { ------------------------------------------------------------------ }
    flatCode[0] := $41; { i32.const }
    flatCode[1] := $15; { 21 }
    flatCode[2] := $10; { call }
    flatCode[3] := $00; { func index 0 }
    flatCode[4] := $0B; { end }

    ctx := make_test_context(@flatCode[0], 5);
    setup_import_section(ctx, 1);
    set_func_import(ctx^.Sections.ImportSection, 0, 'test', 'times2', 0);

    { Type: (i32) -> i32 }
    params[0].ValueType := vti32;
    types[0]._type       := $60;
    types[0].ParamCount  := 1;
    types[0].ParamTypes  := @params[0];
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.TypeSection^.TypeCount := 1;
    ctx^.Sections.TypeSection^.Types := @types[0];

    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 0;
    ctx^.Sections.FunctionSection^.Functions := nil;

    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 0;
    ctx^.Sections.CodeSection^.Entries := nil;

    wasm.wasi.registry.register_host_func(ctx, 'test', 'times2', @mock_times2);
    wasm.wasi.registry.resolve_imports(ctx);
    ctx^.ExecutionState.IP := 0;
    while wasm.vm.tick(ctx) do;

    assert_i32('call import times2(21) => 42',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { ------------------------------------------------------------------ }
    { Test 3: Calling an unresolved import traps                         }
    {   Import 0 = env:missing (not registered)                          }
    {   Code: call 0  end                                                }
    { ------------------------------------------------------------------ }
    flatCode[0] := $10; { call }
    flatCode[1] := $00; { func index 0 }
    flatCode[2] := $0B; { end }

    ctx := make_test_context(@flatCode[0], 3);
    setup_import_section(ctx, 1);
    set_func_import(ctx^.Sections.ImportSection, 0, 'env', 'missing', 0);

    ctx^.Sections.TypeSection := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.TypeSection^.TypeCount := 1;
    types[0]._type       := $60;
    types[0].ParamCount  := 0;
    types[0].ParamTypes  := nil;
    types[0].ReturnCount := 0;
    types[0].ReturnTypes := nil;
    ctx^.Sections.TypeSection^.Types := @types[0];

    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 0;
    ctx^.Sections.FunctionSection^.Functions := nil;

    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 0;
    ctx^.Sections.CodeSection^.Entries := nil;

    wasm.wasi.registry.resolve_imports(ctx);
    ctx^.ExecutionState.IP := 0;
    while wasm.vm.tick(ctx) do;

    assert_bool('unresolved import traps (Running=false)',
                ctx^.ExecutionState.Running, false);

    { ------------------------------------------------------------------ }
    { Test 4: Mixed imports + local functions                            }
    {   Import 0 = test:push99  (func_idx 0)                            }
    {   Local func 0            (func_idx 1): i32.const 7  end          }
    {   Entry: call 0  call 1  i32.add  end                             }
    { ------------------------------------------------------------------ }
    { func 1 (local): i32.const 7, end -> offset 0 }
    flatCode[0]  := $41; { i32.const }
    flatCode[1]  := $07; { 7 }
    flatCode[2]  := $0B; { end }
    { entry code at offset 3: call 0, call 1, i32.add, end }
    flatCode[3]  := $10; { call 0 (import push99) }
    flatCode[4]  := $00;
    flatCode[5]  := $10; { call 1 (local func) }
    flatCode[6]  := $01;
    flatCode[7]  := $6A; { i32.add }
    flatCode[8]  := $0B; { end }

    ctx := make_test_context(@flatCode[0], 9);
    setup_import_section(ctx, 1);
    set_func_import(ctx^.Sections.ImportSection, 0, 'test', 'push99', 0);

    { Types: () -> i32 for both }
    types[0]._type       := $60;
    types[0].ParamCount  := 0;
    types[0].ParamTypes  := nil;
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];

    types[1]._type       := $60;
    types[1].ParamCount  := 0;
    types[1].ParamTypes  := nil;
    types[1].ReturnCount := 1;
    types[1].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.TypeSection^.TypeCount := 2;
    ctx^.Sections.TypeSection^.Types := @types[0];

    { 1 local function: type 1, code at offset 0, length 3 }
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 1;
    ctx^.Sections.FunctionSection^.Functions := PWASMFunction(kalloc(sizeof(TWASMFunction)));
    ctx^.Sections.FunctionSection^.Functions[0].Index := 1;

    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 1;
    ctx^.Sections.CodeSection^.Entries := PWASMCodeEntry(kalloc(sizeof(TWASMCodeEntry)));
    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 3;
    ctx^.Sections.CodeSection^.Entries[0].Code       := @flatCode[0];
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    wasm.wasi.registry.register_host_func(ctx, 'test', 'push99', @mock_push99);
    wasm.wasi.registry.resolve_imports(ctx);
    ctx^.ExecutionState.IP := 3; { start at entry code }
    while wasm.vm.tick(ctx) do;

    { 99 (from import) + 7 (from local) = 106 }
    assert_i32('mixed import+local: 99+7=106',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 106);

    test_end;
end;

end.
