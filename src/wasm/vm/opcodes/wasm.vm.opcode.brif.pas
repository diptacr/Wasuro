unit wasm.vm.opcode.brif;

interface

uses wasm.types.context;

procedure _WASM_opcode_BrIfOp(Context : PWASMProcessContext);

implementation

uses leb128, wasm.types.builtin, wasm.types.stack, wasm.vm.control;

procedure _WASM_opcode_BrIfOp(Context : PWASMProcessContext);
var
    label_depth: TWASMUInt32;
    bytesRead: TWASMUInt8;
    cond: TWASMInt32;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0D }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @label_depth);
    Inc(Context^.ExecutionState.IP, bytesRead); { past label depth }
    cond := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    if cond <> 0 then
        do_branch(Context, label_depth);
    { else: continue at current IP }
end;

end.
