unit wasm.parser.sections.dataSection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types, wasm.types.heap;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
var
   pos, bend : puint8;
   bytesRead : uint8;
   segCount : uint32;
   i, j : uint32;
   memIdx : uint32;
   offset : uint32;
   dataSize : uint32;
   opcode : uint8;
   tmpU32 : uint32;

begin
    writestring('[wasm.parser] Handle Section: Data - Size: ');
    writeintlnWND(section_length, 0);

    pos := buffer;
    bend := puint8(buffer + section_length);

    { Read segment count }
    bytesRead := read_leb128_to_uint32(pos, bend, @segCount);
    Inc(pos, bytesRead);

    for i := 0 to segCount - 1 do begin
        { Read memory index }
        bytesRead := read_leb128_to_uint32(pos, bend, @memIdx);
        Inc(pos, bytesRead);

        { Evaluate offset init expression (expect i32.const N, end) }
        offset := 0;
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

        writestring('[wasm.parser]     Data Segment ');
        writeintWND(i, 0);
        writestring(' - Offset: ');
        writeintWND(offset, 0);
        writestring(' Size: ');
        writeintlnWND(dataSize, 0);

        { Copy bytes into linear memory }
        for j := 0 to dataSize - 1 do begin
            wasm.types.heap.write_uint8(offset + j, ctx^.ExecutionState.Memory, pos^);
            Inc(pos);
        end;
    end;
end;

end.