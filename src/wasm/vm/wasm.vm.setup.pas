unit wasm.vm.setup;

{ Sets up a WASM module for execution.
  - find_start: locates the _start export and prepares a full call frame
    (locals, control stack) so that tick() can begin executing immediately.
  - count_func_imports: counts function-kind imports in the module. }

interface

uses
    wasm.types.builtin, wasm.types.context;

{ Scan the export section for a function export named "_start".
  If found, set up the execution state (IP, locals, control frames)
  so that tick() can run the function.  Returns true on success. }
function find_start(ctx : PWASMProcessContext) : TWASMBoolean;

{ Count the number of function-kind ($00) imports in the module.
  This is needed to convert module-level function indices to local
  code-section indices (local_idx = func_idx - func_import_count). }
function count_func_imports(ctx : PWASMProcessContext) : TWASMUInt32;

implementation

uses
    lmemorymanager, console,
    wasm.types.enums, wasm.types.values, wasm.types.sections,
    wasm.types.stack, wasm.types.constants, wasm.vm.control;

{ ---------- helpers ---------- }

function count_func_imports(ctx : PWASMProcessContext) : TWASMUInt32;
var
    i, count : TWASMUInt32;
begin
    count := 0;
    if ctx^.Sections.ImportSection <> nil then begin
        for i := 0 to ctx^.Sections.ImportSection^.ImportCount - 1 do begin
            if ctx^.Sections.ImportSection^.Entries[i].Desc.Kind = $00 then
                Inc(count);
        end;
    end;
    count_func_imports := count;
end;

{ Compare 6-byte name against '_start'. Bare-metal safe (no sysutils). }
function is_start_name(name : TWASMPChar; len : TWASMUInt32) : TWASMBoolean;
begin
    is_start_name := (len = 6) and
        (name[0] = '_') and (name[1] = 's') and
        (name[2] = 't') and (name[3] = 'a') and
        (name[4] = 'r') and (name[5] = 't');
end;

{ ---------- find_start ---------- }

function find_start(ctx : PWASMProcessContext) : TWASMBoolean;
var
    i, func_idx, local_idx, import_count : TWASMUInt32;
    decl_count, j : TWASMUInt32;
    exp : PWASMExportEntry;
    code_entry : PWASMCodeEntry;
    new_locals : PWASMLocals;
    cs, os : PWASMStack;
begin
    find_start := false;

    if ctx^.Sections.ExportSection = nil then exit;
    if ctx^.Sections.CodeSection   = nil then exit;

    import_count := count_func_imports(ctx);

    for i := 0 to ctx^.Sections.ExportSection^.ExportCount - 1 do begin
        exp := @ctx^.Sections.ExportSection^.Entries[i];

        if (exp^.ExportType <> etFunc) then continue;
        if not is_start_name(exp^.Name, exp^.NameLength) then continue;

        func_idx := exp^.FunctionIndex;

        { Validate: _start must not be an imported function }
        if func_idx < import_count then begin
            console.writestringln('[wasm.vm.setup] Error: _start points to an imported function');
            exit;
        end;

        local_idx := func_idx - import_count;

        if local_idx >= ctx^.Sections.CodeSection^.CodeCount then begin
            console.writestringln('[wasm.vm.setup] Error: _start function index out of range');
            exit;
        end;

        code_entry := @ctx^.Sections.CodeSection^.Entries[local_idx];
        cs := ctx^.ExecutionState.Control_Stack;
        os := ctx^.ExecutionState.Operand_Stack;

        { --- Allocate locals (_start takes no params, only declared locals) --- }
        decl_count := code_entry^.Locals.LocalCount;
        new_locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
        new_locals^.LocalCount := decl_count;
        new_locals^.TypeCount  := decl_count;
        if decl_count > 0 then begin
            new_locals^.Locals := PWASMValueEntry(
                kalloc(sizeof(TWASMValueEntry) * decl_count));
            for j := 0 to decl_count - 1 do begin
                new_locals^.Locals[j].ValueType := code_entry^.Locals.Locals[j].ValueType;
                new_locals^.Locals[j].i64Value  := 0;
            end;
        end else
            new_locals^.Locals := nil;

        { --- Push sentinel call frame --- }
        { saved_locals = nil (no caller), return_ip = Limit (halt), saved_top = 0 }
        wasm.types.stack.pushi64(cs, TWASMInt64(0));
        wasm.types.stack.pushi32(cs, TWASMInt32(ctx^.ExecutionState.Limit));
        wasm.types.stack.pushi32(cs, TWASMInt32(0));
        wasm.types.stack.pushi32(cs, CTRL_FRAME_CALL);

        { --- Push implicit function block frame --- }
        push_control_frame(cs, CTRL_FRAME_BLOCK,
            TWASMInt32(code_entry^.CodeIndex + code_entry^.CodeLength),
            TWASMInt32(os^.Top));

        { --- Activate execution --- }
        ctx^.ExecutionState.IP     := code_entry^.CodeIndex;
        ctx^.ExecutionState.Locals := new_locals;
        ctx^.ExecutionState.Running := true;

        {$IFDEF DEBUG_OUTPUT}
        console.writestring('[wasm.vm.setup] _start found at function index ');
        console.writeintlnWND(func_idx, 0);
        {$ENDIF}

        find_start := true;
        exit;
    end;
end;

end.
