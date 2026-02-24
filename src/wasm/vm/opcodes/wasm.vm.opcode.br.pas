unit wasm.vm.opcode.br;

interface

uses wasm.types.context;

procedure _WASM_opcode_BrOp(Context : PWASMProcessContext);

implementation

uses leb128, wasm.types.builtin, wasm.vm.control;

procedure _WASM_opcode_BrOp(Context : PWASMProcessContext);
var
    label_depth: TWASMUInt32;
    bytesRead: TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0C }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @label_depth);
    { do_branch sets IP; no need to advance past immediate }
    do_branch(Context, label_depth);
end;

end.
