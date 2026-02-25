unit wasm.vm.opcode.brtable;

interface

uses wasm.types.context;

procedure _WASM_opcode_BrTableOp(Context : PWASMProcessContext);

implementation

uses wasm.types.leb128, wasm.types.builtin, wasm.types.stack, wasm.vm.control;

procedure _WASM_opcode_BrTableOp(Context : PWASMProcessContext);
var
    count, idx, selected, dummy: TWASMUInt32;
    skip_count, i: TWASMUInt32;
    bytesRead: TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0E }
    { Read label count }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @count);
    Inc(Context^.ExecutionState.IP, bytesRead);
    { Pop index from operand stack }
    idx := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
    { Determine how many labels to skip to reach our target }
    if idx >= count then
        skip_count := count
    else
        skip_count := idx;
    { Skip labels we don't need }
    for i := 1 to skip_count do begin
        bytesRead := read_leb128_to_uint32(
            @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
            @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
            @dummy);
        Inc(Context^.ExecutionState.IP, bytesRead);
    end;
    { Read the selected label (or default if idx >= count) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @selected);
    { Branch to selected depth }
    do_branch(Context, selected);
end;

end.
