unit wasm.vm.opcode.tablecopy;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableCopyOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.leb128;

{ table.copy x y: [d, s, n] -> []
  Copy n elements from table y at offset s to table x at offset d.
  Handles overlapping correctly. }
procedure _WASM_opcode_TableCopyOp(Context : PWASMProcessContext);
var
    dst_table, src_table : TWASMUInt32;
    bytesRead : TWASMUInt8;
    d, s, n : TWASMInt32;
    i : TWASMUInt32;
begin
    { Read destination table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @dst_table);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Read source table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @src_table);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Pop operands: n, s, d }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    s := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    d := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    { Validate }
    if (dst_table >= Context^.ExecutionState.Tables^.TableCount) or
       (src_table >= Context^.ExecutionState.Tables^.TableCount) then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    if n = 0 then exit;

    if (TWASMUInt32(s) + TWASMUInt32(n) > Context^.ExecutionState.Tables^.Tables[src_table].Size) or
       (TWASMUInt32(d) + TWASMUInt32(n) > Context^.ExecutionState.Tables^.Tables[dst_table].Size) then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    if TWASMUInt32(d) <= TWASMUInt32(s) then begin
        { Forward copy }
        for i := 0 to TWASMUInt32(n) - 1 do
            Context^.ExecutionState.Tables^.Tables[dst_table].Elements[TWASMUInt32(d) + i] :=
                Context^.ExecutionState.Tables^.Tables[src_table].Elements[TWASMUInt32(s) + i];
    end else begin
        { Backward copy }
        for i := TWASMUInt32(n) downto 1 do
            Context^.ExecutionState.Tables^.Tables[dst_table].Elements[TWASMUInt32(d) + i - 1] :=
                Context^.ExecutionState.Tables^.Tables[src_table].Elements[TWASMUInt32(s) + i - 1];
    end;
end;

end.
