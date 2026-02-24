unit wasm.parser.sections.memorySection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types.sections, wasm.types.context, wasm.types.heap;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   i : TWASMUInt32;
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

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   memCount : TWASMUInt32;
   i : TWASMUInt32;
   mem : PWASMMemoryLimits;
   flags : TWASMUInt32;

begin
    {$IFDEF DEBUG_OUTPUT}
     console.writestring('[wasm.parser] Handle Section: Memory - Size: ');
     console.writeintlnWND(section_length, 0);
    {$ENDIF}

    pos := buffer;
    bend := TWASMPUInt8(buffer + section_length);

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
    {$IFDEF DEBUG_OUTPUT}
    walk(ctx);
    {$ENDIF}
end;

end.