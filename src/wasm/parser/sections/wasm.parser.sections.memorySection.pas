unit wasm.parser.sections.memorySection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types, wasm.types.heap;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   i : uint32;
   mem : PWASMMemoryLimits;
begin
    for i := 0 to ctx^.Sections.MemorySection^.MemoryCount - 1 do begin
        mem := @ctx^.Sections.MemorySection^.Memories[i];
        writestring('[wasm.parser]     Memory ');
        writeintWND(i, 0);
        writestring(' - Initial: ');
        writeintWND(mem^.InitialPages, 0);
        if mem^.HasMax then begin
            writestring(' Max: ');
            writeintWND(mem^.MaxPages, 0);
        end;
        writestringln(' ');
    end;
end;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
var
   pos, bend : puint8;
   bytesRead : uint8;
   memCount : uint32;
   i : uint32;
   mem : PWASMMemoryLimits;
   flags : uint32;

begin
    writestring('[wasm.parser] Handle Section: Memory - Size: ');
    writeintlnWND(section_length, 0);

    pos := buffer;
    bend := puint8(buffer + section_length);

    { Read memory count }
    bytesRead := read_leb128_to_uint32(pos, bend, @memCount);
    Inc(pos, bytesRead);

    { Allocate memory section }
    ctx^.Sections.MemorySection := PWASMMemorySection(kalloc(sizeof(TWASMMemorySection)));
    ctx^.Sections.MemorySection^.MemoryCount := memCount;
    ctx^.Sections.MemorySection^.Memories := PWASMMemoryLimits(kalloc(sizeof(TWASMMemoryLimits) * memCount));

    for i := 0 to memCount - 1 do begin
        mem := @ctx^.Sections.MemorySection^.Memories[i];

        { Read limits flags: 0 = no max, 1 = has max }
        bytesRead := read_leb128_to_uint32(pos, bend, @flags);
        Inc(pos, bytesRead);
        mem^.HasMax := (flags = 1);

        { Read initial page count }
        bytesRead := read_leb128_to_uint32(pos, bend, @mem^.InitialPages);
        Inc(pos, bytesRead);

        { Read max page count if present }
        if mem^.HasMax then begin
            bytesRead := read_leb128_to_uint32(pos, bend, @mem^.MaxPages);
            Inc(pos, bytesRead);
        end else
            mem^.MaxPages := $FFFF; { no limit }

        { Expand heap to match initial pages (heap starts with 1 page) }
        while ctx^.ExecutionState.Memory^.PageCount < mem^.InitialPages do
            wasm.types.heap.expand_heap(ctx^.ExecutionState.Memory);
    end;

    walk(ctx);
end;

end.