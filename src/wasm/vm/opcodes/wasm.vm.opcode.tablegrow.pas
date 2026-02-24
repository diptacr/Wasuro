unit wasm.vm.opcode.tablegrow;

interface

uses wasm.types.context;

procedure _WASM_opcode_TableGrowOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, leb128, lmemorymanager;

{ table.grow x: [val, n] -> [i32]
  Grow table x by n elements, initializing with val.
  Returns previous size on success, -1 on failure. }
procedure _WASM_opcode_TableGrowOp(Context : PWASMProcessContext);
var
    table_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
    n, val : TWASMInt32;
    old_size, new_size : TWASMUInt32;
    new_elems : TWASMPUInt32;
    i : TWASMUInt32;
begin
    { Read table index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @table_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Pop operands: n, val }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    if table_idx >= Context^.ExecutionState.Tables^.TableCount then begin
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
        exit;
    end;

    old_size := Context^.ExecutionState.Tables^.Tables[table_idx].Size;
    new_size := old_size + TWASMUInt32(n);

    { Check max limit }
    if Context^.ExecutionState.Tables^.Tables[table_idx].HasMax then begin
        if new_size > Context^.ExecutionState.Tables^.Tables[table_idx].MaxSize then begin
            wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
            exit;
        end;
    end;

    { Allocate new elements array }
    new_elems := TWASMPUInt32(kalloc(new_size * sizeof(TWASMUInt32)));
    if new_elems = nil then begin
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
        exit;
    end;

    { Copy old elements }
    for i := 0 to old_size - 1 do
        new_elems[i] := Context^.ExecutionState.Tables^.Tables[table_idx].Elements[i];

    { Initialize new elements with val }
    for i := old_size to new_size - 1 do
        new_elems[i] := TWASMUInt32(val);

    Context^.ExecutionState.Tables^.Tables[table_idx].Elements := new_elems;
    Context^.ExecutionState.Tables^.Tables[table_idx].Size := new_size;

    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(old_size));
end;

end.
