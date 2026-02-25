unit wasm.test.vm.setup;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.constants,
    wasm.vm.setup,
    wasm.test.framework;

{ Helper: build a minimal context with export section, code section,
  and optionally an import section. Caller owns all memory. }
function build_setup_context(
    exportCount : TWASMUInt32;
    codeCount   : TWASMUInt32;
    importFuncCount : TWASMUInt32
) : PWASMProcessContext;
var
    ctx : PWASMProcessContext;
    code : array[0..0] of TWASMUInt8;
    i : TWASMUInt32;
begin
    code[0] := $0B; { end }
    ctx := make_test_context(@code[0], 1);

    { Export section }
    ctx^.Sections.ExportSection := PWASMExportSection(kalloc(sizeof(TWASMExportSection)));
    ctx^.Sections.ExportSection^.ExportCount := exportCount;
    if exportCount > 0 then
        ctx^.Sections.ExportSection^.Entries :=
            PWASMExportEntry(kalloc(sizeof(TWASMExportEntry) * exportCount))
    else
        ctx^.Sections.ExportSection^.Entries := nil;

    { Code section }
    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := codeCount;
    if codeCount > 0 then
        ctx^.Sections.CodeSection^.Entries :=
            PWASMCodeEntry(kalloc(sizeof(TWASMCodeEntry) * codeCount))
    else
        ctx^.Sections.CodeSection^.Entries := nil;

    { Import section (only function imports for now) }
    if importFuncCount > 0 then begin
        ctx^.Sections.ImportSection := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
        ctx^.Sections.ImportSection^.ImportCount := importFuncCount;
        ctx^.Sections.ImportSection^.Entries :=
            PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * importFuncCount));
        for i := 0 to importFuncCount - 1 do
            ctx^.Sections.ImportSection^.Entries[i].Desc.Kind := $00; { function import }
    end;

    build_setup_context := ctx;
end;

{ Helper: set export entry to a function named "_start" }
procedure set_start_export(exp : PWASMExportEntry; funcIndex : TWASMUInt32);
var
    name : TWASMPChar;
begin
    name := TWASMPChar(kalloc(7));
    name[0] := '_'; name[1] := 's'; name[2] := 't';
    name[3] := 'a'; name[4] := 'r'; name[5] := 't';
    name[6] := #0;
    exp^.Name        := name;
    exp^.NameLength   := 6;
    exp^.ExportType   := etFunc;
    exp^.FunctionIndex := funcIndex;
end;

{ Helper: set up a code entry with N declared i32 locals and a minimal body }
procedure set_code_entry(entry : PWASMCodeEntry; localCount : TWASMUInt32;
                         codeIndex : TWASMUInt32);
var
    i : TWASMUInt32;
begin
    entry^.CodeIndex  := codeIndex;
    entry^.CodeLength := 1; { just the end opcode }
    entry^.Locals.LocalCount := localCount;
    if localCount > 0 then begin
        entry^.Locals.Locals := PWASMValueEntry(
            kalloc(sizeof(TWASMValueEntry) * localCount));
        for i := 0 to localCount - 1 do begin
            entry^.Locals.Locals[i].ValueType := vti32;
            entry^.Locals.Locals[i].i64Value  := 0;
        end;
    end else
        entry^.Locals.Locals := nil;
end;

procedure run;
var
    ctx : PWASMProcessContext;
    result : TWASMBoolean;
    exp : PWASMExportEntry;
    name : TWASMPChar;
begin
    test_begin('vm.setup');

    { ------------------------------------------------------------------ }
    { Test 1: find_start returns false when no export section             }
    { ------------------------------------------------------------------ }
    ctx := make_test_context(nil, 0);
    ctx^.Sections.ExportSection := nil;
    ctx^.Sections.CodeSection := nil;
    ctx^.ExecutionState.Running := false;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('no export section -> false', result, false);
    assert_bool('running stays false', ctx^.ExecutionState.Running, false);

    { ------------------------------------------------------------------ }
    { Test 2: find_start returns false when no code section               }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 0, 0);
    ctx^.Sections.CodeSection := nil;
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 0);
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('no code section -> false', result, false);

    { ------------------------------------------------------------------ }
    { Test 3: find_start returns false when _start not found              }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    { Export a function named "main" instead of "_start" }
    exp := @ctx^.Sections.ExportSection^.Entries[0];
    name := TWASMPChar(kalloc(5));
    name[0] := 'm'; name[1] := 'a'; name[2] := 'i';
    name[3] := 'n'; name[4] := #0;
    exp^.Name        := name;
    exp^.NameLength   := 4;
    exp^.ExportType   := etFunc;
    exp^.FunctionIndex := 0;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('no _start export -> false', result, false);

    { ------------------------------------------------------------------ }
    { Test 4: find_start returns false for memory export named "_start"   }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 0);
    ctx^.Sections.ExportSection^.Entries[0].ExportType := etMemory;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('memory export named _start -> false', result, false);

    { ------------------------------------------------------------------ }
    { Test 5: find_start succeeds with _start, no locals                 }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 0);
    ctx^.ExecutionState.Running := false;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('find_start succeeds', result, true);
    assert_bool('running is true', ctx^.ExecutionState.Running, true);
    assert_u32('IP set to CodeIndex', ctx^.ExecutionState.IP, 0);
    assert_true('locals allocated', ctx^.ExecutionState.Locals <> nil);
    assert_u32('local count is 0', ctx^.ExecutionState.Locals^.LocalCount, 0);
    { Control stack should have 7 entries: call frame (4) + block frame (3) }
    assert_u32('control stack has 7 entries',
        ctx^.ExecutionState.Control_Stack^.Top, 7);

    { ------------------------------------------------------------------ }
    { Test 6: find_start sets up declared locals correctly                }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 3, 0);
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 0);
    ctx^.ExecutionState.Running := false;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('find_start with locals succeeds', result, true);
    assert_u32('3 locals allocated', ctx^.ExecutionState.Locals^.LocalCount, 3);
    assert_true('locals array not nil', ctx^.ExecutionState.Locals^.Locals <> nil);
    { All locals should be zero-initialized }
    assert_i64('local 0 is zero', ctx^.ExecutionState.Locals^.Locals[0].i64Value, 0);
    assert_i64('local 1 is zero', ctx^.ExecutionState.Locals^.Locals[1].i64Value, 0);
    assert_i64('local 2 is zero', ctx^.ExecutionState.Locals^.Locals[2].i64Value, 0);
    { Local types should match code entry }
    assert_true('local 0 is i32',
        ctx^.ExecutionState.Locals^.Locals[0].ValueType = vti32);

    { ------------------------------------------------------------------ }
    { Test 7: find_start with imports adjusts index correctly             }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 2);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 1, 0);
    { _start is func index 2 = first local function (2 imports) }
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 2);
    ctx^.ExecutionState.Running := false;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('find_start with imports succeeds', result, true);
    assert_bool('running after imports', ctx^.ExecutionState.Running, true);
    assert_u32('IP set correctly', ctx^.ExecutionState.IP, 0);
    assert_u32('1 local from code entry', ctx^.ExecutionState.Locals^.LocalCount, 1);

    { ------------------------------------------------------------------ }
    { Test 8: find_start fails when _start points to an import           }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 2);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    { func_idx=1 < import_count=2, so this is an imported function }
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 1);
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('_start as import -> false', result, false);

    { ------------------------------------------------------------------ }
    { Test 9: find_start fails when func index out of range              }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 5);
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('out of range func index -> false', result, false);

    { ------------------------------------------------------------------ }
    { Test 10: count_func_imports with no import section                  }
    { ------------------------------------------------------------------ }
    ctx := make_test_context(nil, 0);
    assert_u32('no imports -> 0', wasm.vm.setup.count_func_imports(ctx), 0);

    { ------------------------------------------------------------------ }
    { Test 11: count_func_imports counts only kind $00                    }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(0, 0, 0);
    ctx^.Sections.ImportSection := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));
    ctx^.Sections.ImportSection^.ImportCount := 3;
    ctx^.Sections.ImportSection^.Entries :=
        PWASMImportEntry(kalloc(sizeof(TWASMImportEntry) * 3));
    ctx^.Sections.ImportSection^.Entries[0].Desc.Kind := $00; { function }
    ctx^.Sections.ImportSection^.Entries[1].Desc.Kind := $02; { memory }
    ctx^.Sections.ImportSection^.Entries[2].Desc.Kind := $00; { function }
    assert_u32('2 func imports', wasm.vm.setup.count_func_imports(ctx), 2);

    { ------------------------------------------------------------------ }
    { Test 12: sentinel call frame has correct layout                     }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(1, 1, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    set_start_export(@ctx^.Sections.ExportSection^.Entries[0], 0);
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('find_start for frame check', result, true);
    { Control stack layout (bottom to top):
      [0] saved_locals (i64=0/nil)
      [1] unused high word
      [2] return_ip (i32=Limit)
      [3] saved_top (i32=0)
      [4] frame_type (i32=CTRL_FRAME_CALL=3)
      [5..7] block frame: target_ip, saved_stack_top, frame_type }
    { Check the call frame marker at entry index 4 (0-based via pushi32) }
    { The top entry (index Top-1) should be CTRL_FRAME_BLOCK=0 for the block frame }
    assert_i32('top frame is block',
        ctx^.ExecutionState.Control_Stack^.Entries[
            ctx^.ExecutionState.Control_Stack^.Top - 1].i32Value,
        CTRL_FRAME_BLOCK);

    { ------------------------------------------------------------------ }
    { Test 13: _start among multiple exports                             }
    { ------------------------------------------------------------------ }
    ctx := build_setup_context(3, 2, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[0], 0, 0);
    set_code_entry(@ctx^.Sections.CodeSection^.Entries[1], 2, 1);
    { Export 0: memory }
    exp := @ctx^.Sections.ExportSection^.Entries[0];
    name := TWASMPChar(kalloc(7));
    name[0] := 'm'; name[1] := 'e'; name[2] := 'm';
    name[3] := 'o'; name[4] := 'r'; name[5] := 'y';
    name[6] := #0;
    exp^.Name        := name;
    exp^.NameLength   := 6;
    exp^.ExportType   := etMemory;
    exp^.FunctionIndex := 0;
    { Export 1: _start -> func index 1 }
    set_start_export(@ctx^.Sections.ExportSection^.Entries[1], 1);
    { Export 2: another function "foo" }
    exp := @ctx^.Sections.ExportSection^.Entries[2];
    name := TWASMPChar(kalloc(4));
    name[0] := 'f'; name[1] := 'o'; name[2] := 'o';
    name[3] := #0;
    exp^.Name        := name;
    exp^.NameLength   := 3;
    exp^.ExportType   := etFunc;
    exp^.FunctionIndex := 0;
    ctx^.ExecutionState.Running := false;
    result := wasm.vm.setup.find_start(ctx);
    assert_bool('_start found among multiple exports', result, true);
    assert_u32('IP matches second code entry', ctx^.ExecutionState.IP, 1);
    assert_u32('2 locals from second entry',
        ctx^.ExecutionState.Locals^.LocalCount, 2);

    test_end;
end;

end.
