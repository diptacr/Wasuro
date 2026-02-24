unit wasm.vm.opcode.elemdrop;

interface

uses wasm.types.context;

procedure _WASM_opcode_ElemDropOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, leb128;

{ elem.drop x: marks element segment x as dropped }
procedure _WASM_opcode_ElemDropOp(Context : PWASMProcessContext);
var
    elem_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
begin
    { Read element segment index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @elem_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    if elem_idx >= Context^.ExecutionState.ElementSegments^.SegmentCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    Context^.ExecutionState.ElementSegments^.Segments[elem_idx].Dropped := true;
end;

end.
