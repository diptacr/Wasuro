unit wasm.vm.opcode.tableget;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableGetOp(Context : PWASMProcessContext);

implementation

uses wasm.types.leb128, wasm.vm.io, wasm.types.builtin, wasm.types.values, wasm.types.sections, wasm.types.stack;

procedure _WASM_opcode_TableGetOp(Context : PWASMProcessContext);
var
    table_idx, elem_idx: TWASMUInt32;
    bytesRead: TWASMUInt8;
    os: PWASMStack;
    tables: PWASMTables;
begin
    os := Context^.ExecutionState.Operand_Stack;

    Inc(Context^.ExecutionState.IP); { past $25 opcode }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    elem_idx := TWASMUInt32(wasm.types.stack.popi32(os));

    tables := Context^.ExecutionState.Tables;

    { Bounds check }
    if (table_idx >= tables^.TableCount) or
       (elem_idx >= tables^.Tables[table_idx].Size) then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: table.get out of bounds');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Push the funcref value }
    wasm.types.stack.pushfunc(os, tables^.Tables[table_idx].Elements[elem_idx]);
end;

end.
