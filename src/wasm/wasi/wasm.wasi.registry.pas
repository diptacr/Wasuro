unit wasm.wasi.registry;
{ Per-context host function registry with dynamic growth.
  Registry types (TWASMHostFuncEntry, TWASMHostFuncRegistry) are
  defined in wasm.types.context. Each TWASMProcessContext owns its
  own registry with no fixed upper limit. }

interface

uses
    wasm.types.builtin,
    wasm.types.context;

const
    REGISTRY_INITIAL_CAPACITY = 16;

procedure init_registry(ctx : PWASMProcessContext);

procedure register_host_func(ctx : PWASMProcessContext;
                             module_name, field_name : TWASMPChar;
                             callback : TWASMHostFunc);

procedure resolve_imports(ctx : PWASMProcessContext);

function  count_func_imports(ctx : PWASMProcessContext) : TWASMUInt32;

implementation

uses
    lmemorymanager, console,
    wasm.types.sections;

{ Compare two null-terminated strings. Returns true if equal. }
function str_eq(a, b : TWASMPChar) : TWASMBoolean;
var
    i : TWASMUInt32;
begin
    i := 0;
    while true do begin
        if a[i] <> b[i] then begin
            str_eq := false;
            exit;
        end;
        if a[i] = #0 then begin
            str_eq := true;
            exit;
        end;
        Inc(i);
    end;
    str_eq := false;
end;

procedure init_registry(ctx : PWASMProcessContext);
begin
    ctx^.HostFuncRegistry.Count := 0;
    ctx^.HostFuncRegistry.Capacity := REGISTRY_INITIAL_CAPACITY;
    ctx^.HostFuncRegistry.Entries :=
        PWASMHostFuncEntry(kalloc(sizeof(TWASMHostFuncEntry) * REGISTRY_INITIAL_CAPACITY));
end;

{ Grow the registry capacity by doubling }
procedure grow_registry(ctx : PWASMProcessContext);
var
    newCap : TWASMUInt32;
    newBuf : PWASMHostFuncEntry;
    i      : TWASMUInt32;
begin
    newCap := ctx^.HostFuncRegistry.Capacity * 2;
    newBuf := PWASMHostFuncEntry(kalloc(sizeof(TWASMHostFuncEntry) * newCap));
    for i := 0 to ctx^.HostFuncRegistry.Count - 1 do
        newBuf[i] := ctx^.HostFuncRegistry.Entries[i];
    kfree(TWASMVoid(ctx^.HostFuncRegistry.Entries));
    ctx^.HostFuncRegistry.Entries := newBuf;
    ctx^.HostFuncRegistry.Capacity := newCap;
end;

procedure register_host_func(ctx : PWASMProcessContext;
                             module_name, field_name : TWASMPChar;
                             callback : TWASMHostFunc);
begin
    { Lazily initialize if never set up }
    if ctx^.HostFuncRegistry.Entries = nil then
        init_registry(ctx);

    { Grow if at capacity }
    if ctx^.HostFuncRegistry.Count >= ctx^.HostFuncRegistry.Capacity then
        grow_registry(ctx);

    ctx^.HostFuncRegistry.Entries[ctx^.HostFuncRegistry.Count].ModuleName := module_name;
    ctx^.HostFuncRegistry.Entries[ctx^.HostFuncRegistry.Count].FieldName  := field_name;
    ctx^.HostFuncRegistry.Entries[ctx^.HostFuncRegistry.Count].Callback   := callback;
    Inc(ctx^.HostFuncRegistry.Count);
end;

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

{ Find a matching registry entry for the given module+field name.
  Returns the index, or $FFFFFFFF if not found. }
function find_in_registry(ctx : PWASMProcessContext;
                          module_name, field_name : TWASMPChar) : TWASMUInt32;
var
    i : TWASMUInt32;
begin
    if ctx^.HostFuncRegistry.Count = 0 then begin
        find_in_registry := $FFFFFFFF;
        exit;
    end;
    for i := 0 to ctx^.HostFuncRegistry.Count - 1 do begin
        if str_eq(ctx^.HostFuncRegistry.Entries[i].ModuleName, module_name) and
           str_eq(ctx^.HostFuncRegistry.Entries[i].FieldName, field_name) then begin
            find_in_registry := i;
            exit;
        end;
    end;
    find_in_registry := $FFFFFFFF;
end;

procedure resolve_imports(ctx : PWASMProcessContext);
var
    i, func_idx, reg_idx, numFuncImports : TWASMUInt32;
begin
    numFuncImports := count_func_imports(ctx);

    ctx^.ResolvedImports.Count := numFuncImports;

    if numFuncImports = 0 then begin
        ctx^.ResolvedImports.Imports := nil;
        exit;
    end;

    ctx^.ResolvedImports.Imports :=
        PWASMResolvedImport(kalloc(sizeof(TWASMResolvedImport) * numFuncImports));

    { Scan imports, picking out Kind=$00 in order }
    func_idx := 0;
    for i := 0 to ctx^.Sections.ImportSection^.ImportCount - 1 do begin
        if ctx^.Sections.ImportSection^.Entries[i].Desc.Kind = $00 then begin
            ctx^.ResolvedImports.Imports[func_idx].ModuleName :=
                ctx^.Sections.ImportSection^.Entries[i].ModuleName;
            ctx^.ResolvedImports.Imports[func_idx].FieldName :=
                ctx^.Sections.ImportSection^.Entries[i].FieldName;

            reg_idx := find_in_registry(ctx,
                ctx^.Sections.ImportSection^.Entries[i].ModuleName,
                ctx^.Sections.ImportSection^.Entries[i].FieldName);

            if reg_idx <> $FFFFFFFF then begin
                ctx^.ResolvedImports.Imports[func_idx].IsResolved := true;
                ctx^.ResolvedImports.Imports[func_idx].Callback :=
                    ctx^.HostFuncRegistry.Entries[reg_idx].Callback;
                {$IFDEF DEBUG_OUTPUT}
                console.writestring('[wasm.wasi.registry] Resolved import: ');
                console.writestring(ctx^.Sections.ImportSection^.Entries[i].ModuleName);
                console.writestring(':');
                console.writestringln(ctx^.Sections.ImportSection^.Entries[i].FieldName);
                {$ENDIF}
            end else begin
                ctx^.ResolvedImports.Imports[func_idx].IsResolved := false;
                ctx^.ResolvedImports.Imports[func_idx].Callback := nil;
                {$IFDEF DEBUG_OUTPUT}
                console.writestring('[wasm.wasi.registry] Unresolved import: ');
                console.writestring(ctx^.Sections.ImportSection^.Entries[i].ModuleName);
                console.writestring(':');
                console.writestringln(ctx^.Sections.ImportSection^.Entries[i].FieldName);
                {$ENDIF}
            end;

            Inc(func_idx);
        end;
    end;
end;

end.
