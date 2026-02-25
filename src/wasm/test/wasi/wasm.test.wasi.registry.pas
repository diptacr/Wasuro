unit wasm.test.wasi.registry;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack,
    wasm.types.wasi,
    wasm.wasi.registry,
    wasm.test.framework;

{ Track whether our mock host function was called and what it did }
var
    mock_called       : TWASMBoolean;
    mock_result_value : TWASMInt32;

{ Mock host function: pops an i32, adds 100, pushes result }
procedure mock_host_add100(Context : PWASMProcessContext);
var
    val : TWASMInt32;
begin
    mock_called := true;
    val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    mock_result_value := val + 100;
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, mock_result_value);
end;

{ Mock host function: pushes 42 onto the stack }
procedure mock_host_push42(Context : PWASMProcessContext);
begin
    mock_called := true;
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 42);
end;

procedure run;
var
    ctx       : PWASMProcessContext;
    importSec : PWASMImportSection;
    code      : array[0..3] of TWASMUInt8;
    modName1, fieldName1, modName2, fieldName2 : TWASMPChar;
    funcImportCount : TWASMUInt32;
    i : TWASMUInt32;
    buf : array[0..15] of TWASMChar;
begin
    test_begin('wasi.registry');

    { ------------------------------------------------------------------ }
    { Test 1: Init registry on context, register host functions          }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    assert_u32('registry initially empty', ctx^.HostFuncRegistry.Count, 0);

    wasm.wasi.registry.register_host_func(ctx,
        'wasi_snapshot_preview1', 'fd_write', @mock_host_push42);
    assert_u32('registry has 1 entry after register', ctx^.HostFuncRegistry.Count, 1);

    wasm.wasi.registry.register_host_func(ctx,
        'wasi_snapshot_preview1', 'proc_exit', @mock_host_add100);
    assert_u32('registry has 2 entries after register', ctx^.HostFuncRegistry.Count, 2);

    { ------------------------------------------------------------------ }
    { Test 2: resolve_imports with matching imports                       }
    { ------------------------------------------------------------------ }
    { Build an import section with 1 function import }
    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 1;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry)));

    { wasi_snapshot_preview1.fd_write }
    modName1 := TWASMPChar(kalloc(26));
    modName1[0]  := 'w'; modName1[1]  := 'a'; modName1[2]  := 's';
    modName1[3]  := 'i'; modName1[4]  := '_'; modName1[5]  := 's';
    modName1[6]  := 'n'; modName1[7]  := 'a'; modName1[8]  := 'p';
    modName1[9]  := 's'; modName1[10] := 'h'; modName1[11] := 'o';
    modName1[12] := 't'; modName1[13] := '_'; modName1[14] := 'p';
    modName1[15] := 'r'; modName1[16] := 'e'; modName1[17] := 'v';
    modName1[18] := 'i'; modName1[19] := 'e'; modName1[20] := 'w';
    modName1[21] := '1'; modName1[22] := #0;

    fieldName1 := TWASMPChar(kalloc(9));
    fieldName1[0] := 'f'; fieldName1[1] := 'd'; fieldName1[2] := '_';
    fieldName1[3] := 'w'; fieldName1[4] := 'r'; fieldName1[5] := 'i';
    fieldName1[6] := 't'; fieldName1[7] := 'e'; fieldName1[8] := #0;

    importSec^.Entries[0].ModuleName := modName1;
    importSec^.Entries[0].ModuleNameLength := 22;
    importSec^.Entries[0].FieldName := fieldName1;
    importSec^.Entries[0].FieldNameLength := 8;
    importSec^.Entries[0].Desc.Kind := $00; { function import }
    importSec^.Entries[0].Desc.TypeIndex := 0;

    ctx^.Sections.ImportSection := importSec;

    wasm.wasi.registry.resolve_imports(ctx);

    assert_u32('resolved imports count = 1', ctx^.ResolvedImports.Count, 1);
    assert_true('import 0 is resolved', ctx^.ResolvedImports.Imports[0].IsResolved);

    { ------------------------------------------------------------------ }
    { Test 3: Call the resolved host function via callback                }
    { ------------------------------------------------------------------ }
    mock_called := false;
    ctx^.ResolvedImports.Imports[0].Callback(ctx);
    assert_true('mock host function was called', mock_called);
    assert_i32('mock pushed 42', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { ------------------------------------------------------------------ }
    { Test 4: Unresolved import (no matching registry entry)             }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);

    { Re-register on this new context }
    wasm.wasi.registry.register_host_func(ctx,
        'wasi_snapshot_preview1', 'fd_write', @mock_host_push42);

    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 1;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry)));

    { env.unknown_func — not registered }
    modName2 := TWASMPChar(kalloc(4));
    modName2[0] := 'e'; modName2[1] := 'n'; modName2[2] := 'v'; modName2[3] := #0;

    fieldName2 := TWASMPChar(kalloc(13));
    fieldName2[0]  := 'u'; fieldName2[1]  := 'n'; fieldName2[2]  := 'k';
    fieldName2[3]  := 'n'; fieldName2[4]  := 'o'; fieldName2[5]  := 'w';
    fieldName2[6]  := 'n'; fieldName2[7]  := '_'; fieldName2[8]  := 'f';
    fieldName2[9]  := 'u'; fieldName2[10] := 'n'; fieldName2[11] := 'c';
    fieldName2[12] := #0;

    importSec^.Entries[0].ModuleName := modName2;
    importSec^.Entries[0].ModuleNameLength := 3;
    importSec^.Entries[0].FieldName := fieldName2;
    importSec^.Entries[0].FieldNameLength := 12;
    importSec^.Entries[0].Desc.Kind := $00;
    importSec^.Entries[0].Desc.TypeIndex := 0;

    ctx^.Sections.ImportSection := importSec;

    wasm.wasi.registry.resolve_imports(ctx);

    assert_u32('unresolved: count = 1', ctx^.ResolvedImports.Count, 1);
    assert_bool('import 0 not resolved', ctx^.ResolvedImports.Imports[0].IsResolved, false);

    { ------------------------------------------------------------------ }
    { Test 5: count_func_imports with interleaved import kinds           }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);

    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 3;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * 3));

    { Entry 0: function import }
    importSec^.Entries[0].Desc.Kind := $00;
    importSec^.Entries[0].ModuleName := modName1;
    importSec^.Entries[0].ModuleNameLength := 22;
    importSec^.Entries[0].FieldName := fieldName1;
    importSec^.Entries[0].FieldNameLength := 8;

    { Entry 1: memory import (Kind=$02) }
    importSec^.Entries[1].Desc.Kind := $02;
    importSec^.Entries[1].ModuleName := modName2;
    importSec^.Entries[1].ModuleNameLength := 3;
    importSec^.Entries[1].FieldName := fieldName2;
    importSec^.Entries[1].FieldNameLength := 12;

    { Entry 2: function import }
    importSec^.Entries[2].Desc.Kind := $00;
    importSec^.Entries[2].ModuleName := modName2;
    importSec^.Entries[2].ModuleNameLength := 3;
    importSec^.Entries[2].FieldName := fieldName2;
    importSec^.Entries[2].FieldNameLength := 12;

    ctx^.Sections.ImportSection := importSec;

    funcImportCount := wasm.wasi.registry.count_func_imports(ctx);
    assert_u32('interleaved: func import count = 2', funcImportCount, 2);

    { ------------------------------------------------------------------ }
    { Test 6: No import section at all                                   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    ctx^.Sections.ImportSection := nil;

    funcImportCount := wasm.wasi.registry.count_func_imports(ctx);
    assert_u32('nil import section: count = 0', funcImportCount, 0);

    wasm.wasi.registry.resolve_imports(ctx);
    assert_u32('nil import section: resolved count = 0', ctx^.ResolvedImports.Count, 0);

    { ------------------------------------------------------------------ }
    { Test 7: Dynamic growth — register >128 custom host functions       }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);

    for i := 0 to 199 do begin
        buf[0] := 'f'; buf[1] := TWASMChar(ord('0') + (i div 100) mod 10);
        buf[2] := TWASMChar(ord('0') + (i div 10) mod 10);
        buf[3] := TWASMChar(ord('0') + i mod 10);
        buf[4] := #0;
        wasm.wasi.registry.register_host_func(ctx, 'mod', @buf[0], @mock_host_push42);
    end;

    assert_u32('200 entries registered', ctx^.HostFuncRegistry.Count, 200);
    assert_true('capacity >= 200', ctx^.HostFuncRegistry.Capacity >= 200);

    { ------------------------------------------------------------------ }
    { Test 8: Two contexts have independent registries                   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.registry.register_host_func(ctx, 'mod', 'func_a', @mock_host_push42);

    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    assert_u32('new ctx registry is empty', ctx^.HostFuncRegistry.Count, 0);

    test_end;
end;

end.
