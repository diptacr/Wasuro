unit wasm.vm.opcode.tableset;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableSetOp(Context : PWASMProcessContext);

implementation

uses leb128, console, wasm.types.builtin, wasm.types.values, wasm.types.sections, wasm.types.stack;

procedure _WASM_opcode_TableSetOp(Context : PWASMProcessContext);
var
    table_idx, elem_idx, val: TWASMUInt32;
    bytesRead: TWASMUInt8;
    os: PWASMStack;
    tables: PWASMTables;
begin
    os := Context^.ExecutionState.Operand_Stack;

    Inc(Context^.ExecutionState.IP); { past $26 opcode }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Pop val (top), then index }
    val := wasm.types.stack.popfunc(os);
    elem_idx := TWASMUInt32(wasm.types.stack.popi32(os));

    tables := Context^.ExecutionState.Tables;

    { Bounds check }
    if (table_idx >= tables^.TableCount) or
       (elem_idx >= tables^.Tables[table_idx].Size) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: table.set out of bounds');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    tables^.Tables[table_idx].Elements[elem_idx] := val;
end;

end.
