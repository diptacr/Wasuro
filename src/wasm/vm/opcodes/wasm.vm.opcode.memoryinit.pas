unit wasm.vm.opcode.memoryinit;

interface

uses wasm.types.context;

procedure _WASM_opcode_MemoryInitOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.heap, wasm.types.leb128, console;

{ memory.init x: [d, s, n] -> []
  Copy n bytes from passive data segment x, starting at offset s,
  to linear memory at offset d }
procedure _WASM_opcode_MemoryInitOp(Context : PWASMProcessContext);
var
    data_idx, mem_idx_byte : TWASMUInt32;
    bytesRead : TWASMUInt8;
    d, s, n : TWASMInt32;
    i : TWASMUInt32;
    seg : pointer;
begin
    { Read data segment index (LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @data_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);

    { Read memory index byte (must be 0x00) }
    mem_idx_byte := Context^.ExecutionState.Code[Context^.ExecutionState.IP];
    Inc(Context^.ExecutionState.IP);

    { Pop operands: n, s, d }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    s := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    d := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    { Validate }
    if data_idx >= Context^.ExecutionState.DataSegments^.SegmentCount then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;
    if Context^.ExecutionState.DataSegments^.Segments[data_idx].Dropped then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    if n = 0 then exit;

    if (s < 0) or (TWASMUInt32(s) + TWASMUInt32(n) > Context^.ExecutionState.DataSegments^.Segments[data_idx].Size) then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Copy bytes from data segment to memory }
    seg := Context^.ExecutionState.DataSegments^.Segments[data_idx].Data;
    for i := 0 to TWASMUInt32(n) - 1 do begin
        if not wasm.types.heap.write_uint8(TWASMUInt32(d) + i, Context^.ExecutionState.Memory,
            TWASMPUInt8(seg)[TWASMUInt32(s) + i]) then begin
            Context^.ExecutionState.Running := false;
            exit;
        end;
    end;
end;

end.
