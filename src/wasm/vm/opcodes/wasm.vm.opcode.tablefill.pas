unit wasm.vm.opcode.tablefill;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableFillOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.leb128;

{ table.fill x: [i, val, n] -> []
  Fill n elements of table x starting at index i with value val }
procedure _WASM_opcode_TableFillOp(Context : PWASMProcessContext);
var
    table_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
    n, val, idx : TWASMInt32;
    j : TWASMUInt32;
begin
    { Read table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Pop operands: n, val, i }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    idx := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    if table_idx >= Context^.ExecutionState.Tables^.TableCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    if n = 0 then exit;

    if TWASMUInt32(idx) + TWASMUInt32(n) > Context^.ExecutionState.Tables^.Tables[table_idx].Size then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    for j := 0 to TWASMUInt32(n) - 1 do
        Context^.ExecutionState.Tables^.Tables[table_idx].Elements[TWASMUInt32(idx) + j] := TWASMUInt32(val);
end;

end.
