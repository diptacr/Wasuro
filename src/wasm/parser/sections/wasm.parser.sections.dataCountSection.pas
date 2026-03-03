unit wasm.parser.sections.dataCountSection;

interface

uses
    wasm.types.builtin, wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, lmemorymanager, wasm.types.sections;

{ DataCount section (ID 12): contains a single u32 count of data segments.
  Pre-allocates the DataSegments array so that bulk memory opcodes
  can reference segments by index during validation. }
procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
    pos, bend : TWASMPUInt8;
    bytesRead : TWASMUInt8;
    dataCount : TWASMUInt32;
begin
    {$IFDEF DEBUG_OUTPUT}
     wasm.vm.io.writestring('[wasm.parser] Handle Section: DataCount - Size: ');
     wasm.vm.io.writeintlnWND(section_length, 0);
    {$ENDIF}

    pos := buffer;
    bend := TWASMPUInt8(buffer + section_length);

    bytesRead := read_leb128_to_uint32(pos, bend, @dataCount);
    Inc(pos, bytesRead);

    {$IFDEF DEBUG_OUTPUT}
    writestring('[wasm.parser]     Data Count: ');
    writeintlnWND(dataCount, 0);
    {$ENDIF}

    { Pre-allocate data segment storage with correct count.
      The actual segment data will be filled when the Data section is parsed. }
    ctx^.ExecutionState.DataSegments^.SegmentCount := dataCount;
    if dataCount > 0 then
        ctx^.ExecutionState.DataSegments^.Segments := PWASMDataSegment(kalloc(dataCount * sizeof(TWASMDataSegment)))
    else
        ctx^.ExecutionState.DataSegments^.Segments := nil;
end;

end.
