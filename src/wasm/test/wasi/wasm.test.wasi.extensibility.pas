unit wasm.test.wasi.extensibility;
{
  Tests that the host function registry supports arbitrary module names,
  not just 'wasi_snapshot_preview1'. This proves the extensibility story:
  an OS can expose custom modules (e.g. wasuro_display, wasuro_gpu) and
  WASM binaries can import from them.
}

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack,
    wasm.wasi.registry,
    wasm.test.framework;

{ --- Mock host functions for custom modules --- }

var
    display_called : TWASMBoolean;
    gpu_called     : TWASMBoolean;
    wasi_called    : TWASMBoolean;

procedure mock_display_clear(Context : PWASMProcessContext);
var
    color : TWASMInt32;
begin
    display_called := true;
    color := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    { push success }
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure mock_gpu_draw_rect(Context : PWASMProcessContext);
var
    x, y, w, h : TWASMInt32;
begin
    gpu_called := true;
    h := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    w := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    y := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    x := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    { push success }
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure mock_wasi_fd_write(Context : PWASMProcessContext);
begin
    wasi_called := true;
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

{ Helper: allocate a null-terminated string via kalloc }
function make_pchar(s : TWASMPChar; len : TWASMUInt32) : TWASMPChar;
var
    p : TWASMPChar;
    i : TWASMUInt32;
begin
    p := TWASMPChar(kalloc(len + 1));
    for i := 0 to len - 1 do
        p[i] := s[i];
    p[len] := #0;
    make_pchar := p;
end;

procedure run;
var
    ctx         : PWASMProcessContext;
    importSec   : PWASMImportSection;
    code        : array[0..3] of TWASMUInt8;
    mDisplay, fClear      : TWASMPChar;
    mGpu, fDrawRect       : TWASMPChar;
    mWasi, fFdWrite       : TWASMPChar;
    mUnknown, fUnknown    : TWASMPChar;
begin
    test_begin('wasi.extensibility');

    { Allocate module/field names }
    mDisplay  := make_pchar('wasuro_display', 14);
    fClear    := make_pchar('clear_screen', 12);
    mGpu      := make_pchar('wasuro_gpu', 10);
    fDrawRect := make_pchar('draw_rect', 9);
    mWasi     := make_pchar('wasi_snapshot_preview1', 22);
    fFdWrite  := make_pchar('fd_write', 8);
    mUnknown  := make_pchar('unknown_module', 14);
    fUnknown  := make_pchar('unknown_func', 12);

    { ------------------------------------------------------------------ }
    { Test 1: Register functions from multiple modules                   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);

    wasm.wasi.registry.register_host_func(ctx,
        mWasi, fFdWrite, @mock_wasi_fd_write);
    wasm.wasi.registry.register_host_func(ctx,
        mDisplay, fClear, @mock_display_clear);
    wasm.wasi.registry.register_host_func(ctx,
        mGpu, fDrawRect, @mock_gpu_draw_rect);

    assert_u32('3 entries from 3 modules', ctx^.HostFuncRegistry.Count, 3);

    { ------------------------------------------------------------------ }
    { Test 2: Resolve imports from mixed modules                         }
    { ------------------------------------------------------------------ }
    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 4;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * 4));

    { Import 0: wasuro_display.clear_screen }
    importSec^.Entries[0].ModuleName := mDisplay;
    importSec^.Entries[0].ModuleNameLength := 14;
    importSec^.Entries[0].FieldName := fClear;
    importSec^.Entries[0].FieldNameLength := 12;
    importSec^.Entries[0].Desc.Kind := $00;
    importSec^.Entries[0].Desc.TypeIndex := 0;

    { Import 1: wasi_snapshot_preview1.fd_write }
    importSec^.Entries[1].ModuleName := mWasi;
    importSec^.Entries[1].ModuleNameLength := 22;
    importSec^.Entries[1].FieldName := fFdWrite;
    importSec^.Entries[1].FieldNameLength := 8;
    importSec^.Entries[1].Desc.Kind := $00;
    importSec^.Entries[1].Desc.TypeIndex := 0;

    { Import 2: wasuro_gpu.draw_rect }
    importSec^.Entries[2].ModuleName := mGpu;
    importSec^.Entries[2].ModuleNameLength := 10;
    importSec^.Entries[2].FieldName := fDrawRect;
    importSec^.Entries[2].FieldNameLength := 9;
    importSec^.Entries[2].Desc.Kind := $00;
    importSec^.Entries[2].Desc.TypeIndex := 0;

    { Import 3: unknown_module.unknown_func — NOT registered }
    importSec^.Entries[3].ModuleName := mUnknown;
    importSec^.Entries[3].ModuleNameLength := 14;
    importSec^.Entries[3].FieldName := fUnknown;
    importSec^.Entries[3].FieldNameLength := 12;
    importSec^.Entries[3].Desc.Kind := $00;
    importSec^.Entries[3].Desc.TypeIndex := 0;

    ctx^.Sections.ImportSection := importSec;

    wasm.wasi.registry.resolve_imports(ctx);

    assert_u32('4 func imports resolved', ctx^.ResolvedImports.Count, 4);
    assert_true('import 0 (display) resolved', ctx^.ResolvedImports.Imports[0].IsResolved);
    assert_true('import 1 (wasi) resolved', ctx^.ResolvedImports.Imports[1].IsResolved);
    assert_true('import 2 (gpu) resolved', ctx^.ResolvedImports.Imports[2].IsResolved);
    assert_bool('import 3 (unknown) unresolved', ctx^.ResolvedImports.Imports[3].IsResolved, false);

    { ------------------------------------------------------------------ }
    { Test 3: Call custom module callbacks                               }
    { ------------------------------------------------------------------ }
    display_called := false;
    gpu_called := false;
    wasi_called := false;

    { Call display.clear_screen(color=0xFF0000) }
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, $FF0000);
    ctx^.ResolvedImports.Imports[0].Callback(ctx);
    assert_true('display callback invoked', display_called);
    assert_i32('display returns 0', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Call gpu.draw_rect(x=10, y=20, w=100, h=50) }
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 10);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 20);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 100);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 50);
    ctx^.ResolvedImports.Imports[2].Callback(ctx);
    assert_true('gpu callback invoked', gpu_called);
    assert_i32('gpu returns 0', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { Call wasi.fd_write }
    ctx^.ResolvedImports.Imports[1].Callback(ctx);
    assert_true('wasi callback invoked', wasi_called);
    assert_i32('wasi returns 0', wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 0);

    { ------------------------------------------------------------------ }
    { Test 4: Same field name in different modules resolves independently }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);

    { Register 'init' in two different modules }
    wasm.wasi.registry.register_host_func(ctx,
        mDisplay, make_pchar('init', 4), @mock_display_clear);
    wasm.wasi.registry.register_host_func(ctx,
        mGpu, make_pchar('init', 4), @mock_gpu_draw_rect);

    assert_u32('2 init entries from 2 modules', ctx^.HostFuncRegistry.Count, 2);

    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 2;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * 2));

    { Import 0: wasuro_display.init }
    importSec^.Entries[0].ModuleName := mDisplay;
    importSec^.Entries[0].ModuleNameLength := 14;
    importSec^.Entries[0].FieldName := make_pchar('init', 4);
    importSec^.Entries[0].FieldNameLength := 4;
    importSec^.Entries[0].Desc.Kind := $00;
    importSec^.Entries[0].Desc.TypeIndex := 0;

    { Import 1: wasuro_gpu.init }
    importSec^.Entries[1].ModuleName := mGpu;
    importSec^.Entries[1].ModuleNameLength := 10;
    importSec^.Entries[1].FieldName := make_pchar('init', 4);
    importSec^.Entries[1].FieldNameLength := 4;
    importSec^.Entries[1].Desc.Kind := $00;
    importSec^.Entries[1].Desc.TypeIndex := 0;

    ctx^.Sections.ImportSection := importSec;
    wasm.wasi.registry.resolve_imports(ctx);

    assert_true('display.init resolved', ctx^.ResolvedImports.Imports[0].IsResolved);
    assert_true('gpu.init resolved', ctx^.ResolvedImports.Imports[1].IsResolved);

    { Verify they dispatch to different callbacks }
    display_called := false;
    gpu_called := false;

    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    ctx^.ResolvedImports.Imports[0].Callback(ctx);
    wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack); { discard result }
    assert_true('display.init called display handler', display_called);
    assert_bool('display.init did not call gpu handler', gpu_called, false);

    display_called := false;
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.types.stack.pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    ctx^.ResolvedImports.Imports[1].Callback(ctx);
    wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack); { discard result }
    assert_true('gpu.init called gpu handler', gpu_called);
    assert_bool('gpu.init did not call display handler', display_called, false);

    { ------------------------------------------------------------------ }
    { Test 5: Non-function imports are skipped during resolution         }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.registry.register_host_func(ctx,
        mDisplay, fClear, @mock_display_clear);

    importSec := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    importSec^.ImportCount := 3;
    importSec^.Entries := PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * 3));

    { Entry 0: memory import (Kind=$02) — should be skipped }
    importSec^.Entries[0].Desc.Kind := $02;
    importSec^.Entries[0].ModuleName := mDisplay;
    importSec^.Entries[0].ModuleNameLength := 14;
    importSec^.Entries[0].FieldName := make_pchar('memory', 6);
    importSec^.Entries[0].FieldNameLength := 6;

    { Entry 1: function import from custom module }
    importSec^.Entries[1].Desc.Kind := $00;
    importSec^.Entries[1].ModuleName := mDisplay;
    importSec^.Entries[1].ModuleNameLength := 14;
    importSec^.Entries[1].FieldName := fClear;
    importSec^.Entries[1].FieldNameLength := 12;
    importSec^.Entries[1].Desc.TypeIndex := 0;

    { Entry 2: global import (Kind=$03) — should be skipped }
    importSec^.Entries[2].Desc.Kind := $03;
    importSec^.Entries[2].ModuleName := mDisplay;
    importSec^.Entries[2].ModuleNameLength := 14;
    importSec^.Entries[2].FieldName := make_pchar('version', 7);
    importSec^.Entries[2].FieldNameLength := 7;

    ctx^.Sections.ImportSection := importSec;
    wasm.wasi.registry.resolve_imports(ctx);

    assert_u32('only 1 func import among 3 entries', ctx^.ResolvedImports.Count, 1);
    assert_true('custom func import resolved', ctx^.ResolvedImports.Imports[0].IsResolved);

    test_end;
end;

end.
