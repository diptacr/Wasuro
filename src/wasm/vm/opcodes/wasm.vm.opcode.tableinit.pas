unit wasm.vm.opcode.tableinit;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableInitOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, leb128;

{ table.init x y: [d, s, n] -> []
  Copy n elements from element segment y, starting at offset s,
  to table x at offset d }
procedure _WASM_opcode_TableInitOp(Context : PWASMProcessContext);
var
    elem_idx, table_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
    d, s, n : TWASMInt32;
    i : TWASMUInt32;
    tables : pointer;
    elems : pointer;
begin
    { Read element segment index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @elem_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Read table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Pop operands: n, s, d }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    s := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    d := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    { Validate }
    if table_idx >= Context^.ExecutionState.Tables^.TableCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;
    if elem_idx >= Context^.ExecutionState.ElementSegments^.SegmentCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;
    if Context^.ExecutionState.ElementSegments^.Segments[elem_idx].Dropped then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    if n = 0 then exit;

    if (TWASMUInt32(s) + TWASMUInt32(n) > Context^.ExecutionState.ElementSegments^.Segments[elem_idx].FuncCount) or
       (TWASMUInt32(d) + TWASMUInt32(n) > Context^.ExecutionState.Tables^.Tables[table_idx].Size) then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    for i := 0 to TWASMUInt32(n) - 1 do begin
        Context^.ExecutionState.Tables^.Tables[table_idx].Elements[TWASMUInt32(d) + i] :=
            Context^.ExecutionState.ElementSegments^.Segments[elem_idx].FuncIndices[TWASMUInt32(s) + i];
    end;
end;

end.
