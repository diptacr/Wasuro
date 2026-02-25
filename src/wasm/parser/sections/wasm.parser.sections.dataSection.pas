unit wasm.parser.sections.dataSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, wasm.types.leb128,
    wasm.types.sections, wasm.types.context, wasm.types.heap;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   segCount : TWASMUInt32;
   i, j : TWASMUInt32;
   mode : TWASMUInt32;
   memIdx : TWASMUInt32;
   offset : TWASMUInt32;
   dataSize : TWASMUInt32;
   opcode : TWASMUInt8;
   tmpU32 : TWASMUInt32;
   segData : TWASMPUInt8;

begin
    {$IFDEF DEBUG_OUTPUT}
     console.writestring('[wasm.parser] Handle Section: Data - Size: ');
     console.writeintlnWND(section_length, 0);
    {$ENDIF}

    pos := buffer;
    bend := TWASMPUInt8(buffer + section_length);

    { Read segment count }
    bytesRead := read_leb128_to_uint32(pos, bend, @segCount);
    Inc(pos, bytesRead);

    { Allocate data segments storage (or use pre-allocated from DataCount section) }
    if ctx^.ExecutionState.DataSegments^.SegmentCount < segCount then begin
        ctx^.ExecutionState.DataSegments^.SegmentCount := segCount;
        if segCount > 0 then
            ctx^.ExecutionState.DataSegments^.Segments := PWASMDataSegment(kalloc(segCount * sizeof(TWASMDataSegment)))
        else
            ctx^.ExecutionState.DataSegments^.Segments := nil;
    end;

    for i := 0 to segCount - 1 do begin
        { Read mode byte }
        bytesRead := read_leb128_to_uint32(pos, bend, @mode);
        Inc(pos, bytesRead);

        offset := 0;
        memIdx := 0;

        if mode = 0 then begin
            { Mode 0: active segment, implicit memory 0, offset expression }
            opcode := pos^;
            Inc(pos);
            if opcode = $41 then begin { i32.const }
                bytesRead := read_leb128_to_uint32(pos, bend, @tmpU32);
                Inc(pos, bytesRead);
                offset := tmpU32;
            end else begin
                writestring('[wasm.parser] Warning: unsupported data offset opcode: ');
                writehexpair(opcode);
                writestringln(' ');
                while (pos < bend) and (pos^ <> $0B) do Inc(pos);
            end;
            { Consume end ($0B) }
            if (pos < bend) and (pos^ = $0B) then
                Inc(pos);

            { Read data byte count }
            bytesRead := read_leb128_to_uint32(pos, bend, @dataSize);
            Inc(pos, bytesRead);

            {$IFDEF DEBUG_OUTPUT}
            writestring('[wasm.parser]     Data Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 0 Offset: ');
            writeintWND(offset, 0);
            writestring(' Size: ');
            writeintlnWND(dataSize, 0);
            {$ENDIF}

            { Store segment data for bulk memory ops }
            segData := TWASMPUInt8(kalloc(dataSize));
            for j := 0 to dataSize - 1 do
                segData[j] := pos[j];
            ctx^.ExecutionState.DataSegments^.Segments[i].Data := segData;
            ctx^.ExecutionState.DataSegments^.Segments[i].Size := dataSize;
            ctx^.ExecutionState.DataSegments^.Segments[i].Dropped := true; { active = dropped after init }

            { Copy bytes into linear memory }
            for j := 0 to dataSize - 1 do begin
                wasm.types.heap.write_uint8(offset + j, ctx^.ExecutionState.Memory, pos^);
                Inc(pos);
            end;

        end else if mode = 1 then begin
            { Mode 1: passive segment — no memory target, no offset, just data }
            bytesRead := read_leb128_to_uint32(pos, bend, @dataSize);
            Inc(pos, bytesRead);

            {$IFDEF DEBUG_OUTPUT}
            writestring('[wasm.parser]     Data Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 1 (passive) Size: ');
            writeintlnWND(dataSize, 0);
            {$ENDIF}

            { Store segment data for bulk memory ops }
            segData := TWASMPUInt8(kalloc(dataSize));
            for j := 0 to dataSize - 1 do begin
                segData[j] := pos^;
                Inc(pos);
            end;
            ctx^.ExecutionState.DataSegments^.Segments[i].Data := segData;
            ctx^.ExecutionState.DataSegments^.Segments[i].Size := dataSize;
            ctx^.ExecutionState.DataSegments^.Segments[i].Dropped := false; { passive = available }

        end else if mode = 2 then begin
            { Mode 2: active with explicit memory index, offset expression }
            bytesRead := read_leb128_to_uint32(pos, bend, @memIdx);
            Inc(pos, bytesRead);

            opcode := pos^;
            Inc(pos);
            if opcode = $41 then begin { i32.const }
                bytesRead := read_leb128_to_uint32(pos, bend, @tmpU32);
                Inc(pos, bytesRead);
                offset := tmpU32;
            end else begin
                writestring('[wasm.parser] Warning: unsupported data offset opcode: ');
                writehexpair(opcode);
                writestringln(' ');
                while (pos < bend) and (pos^ <> $0B) do Inc(pos);
            end;
            { Consume end ($0B) }
            if (pos < bend) and (pos^ = $0B) then
                Inc(pos);

            { Read data byte count }
            bytesRead := read_leb128_to_uint32(pos, bend, @dataSize);
            Inc(pos, bytesRead);

            {$IFDEF DEBUG_OUTPUT}
            writestring('[wasm.parser]     Data Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 2 MemIdx: ');
            writeintWND(memIdx, 0);
            writestring(' Offset: ');
            writeintWND(offset, 0);
            writestring(' Size: ');
            writeintlnWND(dataSize, 0);
            {$ENDIF}

            { Store segment data for bulk memory ops }
            segData := TWASMPUInt8(kalloc(dataSize));
            for j := 0 to dataSize - 1 do
                segData[j] := pos[j];
            ctx^.ExecutionState.DataSegments^.Segments[i].Data := segData;
            ctx^.ExecutionState.DataSegments^.Segments[i].Size := dataSize;
            ctx^.ExecutionState.DataSegments^.Segments[i].Dropped := true; { active = dropped after init }

            { Copy bytes into linear memory }
            for j := 0 to dataSize - 1 do begin
                wasm.types.heap.write_uint8(offset + j, ctx^.ExecutionState.Memory, pos^);
                Inc(pos);
            end;

        end else begin
            writestring('[wasm.parser] Warning: unknown data segment mode: ');
            writeintlnWND(mode, 0);
            break;
        end;
    end;
end;

end.