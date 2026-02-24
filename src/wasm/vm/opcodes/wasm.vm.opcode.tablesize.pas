unit wasm.vm.opcode.tablesize;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableSizeOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, leb128;

{ table.size x: [] -> [i32]
  Returns the current size of table x }
procedure _WASM_opcode_TableSizeOp(Context : PWASMProcessContext);
var
    table_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
begin
    { Read table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    if table_idx >= Context^.ExecutionState.Tables^.TableCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack,
        TWASMInt32(Context^.ExecutionState.Tables^.Tables[table_idx].Size));
end;

end.
