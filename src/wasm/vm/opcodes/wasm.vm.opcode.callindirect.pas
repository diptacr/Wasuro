unit wasm.vm.opcode.callindirect;

interface

uses wasm.types.context;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);

implementation

uses wasm.types.leb128, lmemorymanager, wasm.vm.io,
     wasm.types.builtin, wasm.types.enums,
     wasm.types.values, wasm.types.sections, wasm.types.stack,
     wasm.types.constants, wasm.vm.control;

function types_match(a, b: PWASMType): TWASMBoolean;
var
    i: TWASMUInt32;
begin
    if a^.ParamCount <> b^.ParamCount then begin types_match := false; exit; end;
    if a^.ReturnCount <> b^.ReturnCount then begin types_match := false; exit; end;
    for i := 0 to a^.ParamCount - 1 do
        if a^.ParamTypes[i].ValueType <> b^.ParamTypes[i].ValueType then begin
            types_match := false; exit;
        end;
    for i := 0 to a^.ReturnCount - 1 do
        if a^.ReturnTypes[i].ValueType <> b^.ReturnTypes[i].ValueType then begin
            types_match := false; exit;
        end;
    types_match := true;
end;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);
var
    expected_type_idx, table_idx_byte: TWASMUInt32;
    elem_idx, func_idx, actual_type_idx: TWASMUInt32;
    bytesRead: TWASMUInt8;
    expected_type, actual_type: PWASMType;
    code_entry: PWASMCodeEntry;
    param_count, decl_count, total_count: TWASMUInt32;
    new_locals: PWASMLocals;
    i, j: TWASMUInt32;
    return_ip, saved_top: TWASMUInt32;
    cs, os: PWASMStack;
    tables: PWASMTables;
    import_func_count, local_idx: TWASMUInt32;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;

    Inc(Context^.ExecutionState.IP); { past $11 opcode }

    { Read type index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @expected_type_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Read table index (single byte in WASM 1.0) }
    table_idx_byte := Context^.ExecutionState.Code[Context^.ExecutionState.IP];
    Inc(Context^.ExecutionState.IP);

    return_ip := Context^.ExecutionState.IP;

    { Pop element index from stack }
    elem_idx := TWASMUInt32(wasm.types.stack.popi32(os));

    tables := Context^.ExecutionState.Tables;

    { Bounds check: table exists }
    if table_idx_byte >= tables^.TableCount then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: call_indirect - table index out of range');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Bounds check: element index within table }
    if elem_idx >= tables^.Tables[table_idx_byte].Size then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: call_indirect - element index out of bounds');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Look up function index from table }
    func_idx := tables^.Tables[table_idx_byte].Elements[elem_idx];

    { Check for uninitialized table element }
    if func_idx = $FFFFFFFF then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: call_indirect - uninitialized table element');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Determine how many function imports exist }
    import_func_count := Context^.ResolvedImports.Count;

    { Check if this is a host function call (import) }
    if func_idx < import_func_count then begin
        if Context^.ResolvedImports.Imports[func_idx].IsResolved then begin
            Context^.ResolvedImports.Imports[func_idx].Callback(Context);
        end else begin
            wasm.vm.io.writestring('[wasm.vm] Trap: call_indirect to unresolved import "');
            wasm.vm.io.writestring(Context^.ResolvedImports.Imports[func_idx].ModuleName);
            wasm.vm.io.writestring(':');
            wasm.vm.io.writestring(Context^.ResolvedImports.Imports[func_idx].FieldName);
            wasm.vm.io.writestringln('"');
            Context^.ExecutionState.Running := false;
        end;
        exit;
    end;

    { Adjust to local function index }
    local_idx := func_idx - import_func_count;

    { Validate function index }
    if local_idx >= Context^.Sections.FunctionSection^.FunctionCount then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: call_indirect - function index out of range');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Type check: compare expected type with actual function type }
    actual_type_idx := Context^.Sections.FunctionSection^.Functions[local_idx].Index;
    expected_type := @Context^.Sections.TypeSection^.Types[expected_type_idx];
    actual_type := @Context^.Sections.TypeSection^.Types[actual_type_idx];

    if (expected_type_idx <> actual_type_idx) and (not types_match(expected_type, actual_type)) then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: call_indirect - type mismatch');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Perform the call — same as CallOp but using the looked-up local_idx }
    code_entry := @Context^.Sections.CodeSection^.Entries[local_idx];

    param_count := actual_type^.ParamCount;
    decl_count  := code_entry^.Locals.LocalCount;
    total_count := param_count + decl_count;

    new_locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
    new_locals^.LocalCount := total_count;
    new_locals^.TypeCount  := total_count;
    if total_count > 0 then
        new_locals^.Locals := PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * total_count))
    else
        new_locals^.Locals := nil;

    if param_count > 0 then begin
        for i := param_count downto 1 do begin
            j := i - 1;
            new_locals^.Locals[j].ValueType := actual_type^.ParamTypes[j].ValueType;
            case actual_type^.ParamTypes[j].ValueType of
                vti32: new_locals^.Locals[j].i32Value := wasm.types.stack.popi32(os);
                vti64: new_locals^.Locals[j].i64Value := wasm.types.stack.popi64(os);
                vtf32: new_locals^.Locals[j].f32Value := wasm.types.stack.popf32(os);
                vtf64: new_locals^.Locals[j].f64Value := wasm.types.stack.popf64(os);
            end;
        end;
    end;

    if decl_count > 0 then begin
        for i := param_count to total_count - 1 do begin
            j := i - param_count;
            new_locals^.Locals[i].ValueType := code_entry^.Locals.Locals[j].ValueType;
            new_locals^.Locals[i].i64Value := 0;
        end;
    end;

    saved_top := os^.Top;

    wasm.types.stack.pushi64(cs, TWASMInt64(Context^.ExecutionState.Locals));
    wasm.types.stack.pushi32(cs, TWASMInt32(return_ip));
    wasm.types.stack.pushi32(cs, TWASMInt32(saved_top));
    wasm.types.stack.pushi32(cs, CTRL_FRAME_CALL);

    push_control_frame(cs, CTRL_FRAME_BLOCK,
                       TWASMInt32(code_entry^.CodeIndex + code_entry^.CodeLength),
                       TWASMInt32(os^.Top));

    Context^.ExecutionState.IP     := code_entry^.CodeIndex;
    Context^.ExecutionState.Locals := new_locals;
end;

end.
