unit wasm.vm.opcode.call;

interface

uses wasm.types.context;

procedure _WASM_opcode_CallOp(Context : PWASMProcessContext);

implementation

uses wasm.types.leb128, lmemorymanager, wasm.vm.io, wasm.types.builtin, wasm.types.enums,
     wasm.types.values, wasm.types.sections, wasm.types.stack,
     wasm.types.constants, wasm.vm.control;

procedure _WASM_opcode_CallOp(Context : PWASMProcessContext);
var
    func_idx, type_idx: TWASMUInt32;
    bytesRead: TWASMUInt8;
    func_type: PWASMType;
    code_entry: PWASMCodeEntry;
    param_count, decl_count, total_count: TWASMUInt32;
    new_locals: PWASMLocals;
    i, j: TWASMUInt32;
    return_ip, saved_top: TWASMUInt32;
    cs, os: PWASMStack;
    import_func_count, local_idx: TWASMUInt32;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;

    Inc(Context^.ExecutionState.IP); { past opcode $10 }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @func_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Determine how many function imports exist }
    import_func_count := Context^.ResolvedImports.Count;

    if func_idx < import_func_count then begin
        { --- Host function call (import) --- }
        if Context^.ResolvedImports.Imports[func_idx].IsResolved then begin
            Context^.ResolvedImports.Imports[func_idx].Callback(Context);
            { Callback has already popped args and pushed results.
              IP already advanced past the call instruction. }
        end else begin
            { Trap: unresolved import }
            wasm.vm.io.writestring('[wasm.vm] Trap: call to unresolved import "');
            wasm.vm.io.writestring(Context^.ResolvedImports.Imports[func_idx].ModuleName);
            wasm.vm.io.writestring(':');
            wasm.vm.io.writestring(Context^.ResolvedImports.Imports[func_idx].FieldName);
            wasm.vm.io.writestringln('"');
            Context^.ExecutionState.Running := false;
        end;
        exit;
    end;

    { --- Module function call (existing logic with adjusted index) --- }
    local_idx := func_idx - import_func_count;
    return_ip := Context^.ExecutionState.IP; { instruction after call }

    { Look up function metadata }
    type_idx   := Context^.Sections.FunctionSection^.Functions[local_idx].Index;
    func_type  := @Context^.Sections.TypeSection^.Types[type_idx];
    code_entry := @Context^.Sections.CodeSection^.Entries[local_idx];

    param_count := func_type^.ParamCount;
    decl_count  := code_entry^.Locals.LocalCount;
    total_count := param_count + decl_count;

    { Allocate new locals }
    new_locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
    new_locals^.LocalCount := total_count;
    new_locals^.TypeCount  := total_count;
    if total_count > 0 then
        new_locals^.Locals := PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * total_count))
    else
        new_locals^.Locals := nil;

    { Pop parameters from operand stack (reverse order into locals) }
    if param_count > 0 then begin
        for i := param_count downto 1 do begin
            j := i - 1;
            new_locals^.Locals[j].ValueType := func_type^.ParamTypes[j].ValueType;
            case func_type^.ParamTypes[j].ValueType of
                vti32: new_locals^.Locals[j].i32Value := wasm.types.stack.popi32(os);
                vti64: new_locals^.Locals[j].i64Value := wasm.types.stack.popi64(os);
                vtf32: new_locals^.Locals[j].f32Value := wasm.types.stack.popf32(os);
                vtf64: new_locals^.Locals[j].f64Value := wasm.types.stack.popf64(os);
            end;
        end;
    end;

    { Initialize declared locals to zero }
    if decl_count > 0 then begin
        for i := param_count to total_count - 1 do begin
            j := i - param_count;
            new_locals^.Locals[i].ValueType := code_entry^.Locals.Locals[j].ValueType;
            new_locals^.Locals[i].i64Value := 0;
        end;
    end;

    saved_top := os^.Top; { stack depth after popping args }

    { Push call frame (4 entries): saved_locals_ptr, return_ip, saved_top, marker }
    wasm.types.stack.pushi64(cs, TWASMInt64(Context^.ExecutionState.Locals));
    wasm.types.stack.pushi32(cs, TWASMInt32(return_ip));
    wasm.types.stack.pushi32(cs, TWASMInt32(saved_top));
    wasm.types.stack.pushi32(cs, CTRL_FRAME_CALL);

    { Push implicit function block frame }
    push_control_frame(cs, CTRL_FRAME_BLOCK,
                       TWASMInt32(code_entry^.CodeIndex + code_entry^.CodeLength),
                       TWASMInt32(os^.Top));

    { Switch to callee }
    Context^.ExecutionState.IP     := code_entry^.CodeIndex;
    Context^.ExecutionState.Locals := new_locals;
end;

end.
