unit wasm.vm.opcode.datadrop;

interface

uses wasm.types.context;

procedure _WASM_opcode_DataDropOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.leb128;

{ data.drop x: marks data segment x as dropped }
procedure _WASM_opcode_DataDropOp(Context : PWASMProcessContext);
var
    data_idx : TWASMUInt32;
    bytesRead : TWASMUInt8;
begin
    { Read data segment index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @data_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    if data_idx >= Context^.ExecutionState.DataSegments^.SegmentCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    Context^.ExecutionState.DataSegments^.Segments[data_idx].Dropped := true;
end;

end.
