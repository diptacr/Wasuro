unit wasm.parser;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types, wasm.types.heap, wasm.types.stack,
    wasm.parser.sections;

function parse(buffer: puint8; buffer_end: puint8) : PWASMProcessContext;

implementation

function newContext() : PWASMProcessContext;
var
    ctx : PWASMProcessContext;

begin
    // Allocate the context
    ctx:= PWASMProcessContext(kalloc(SizeOf(TWASMProcessContext)));

    // Initialize the context
    ctx^.ValidBinary:= false;
    ctx^.Version:= 0;

    // Initialize the execution state
    ctx^.ExecutionState.Memory:= wasm.types.heap.new_heap();
    ctx^.ExecutionState.Control_Stack:= wasm.types.stack.newDefaultStack();
    ctx^.ExecutionState.Operand_Stack:= wasm.types.stack.newDefaultStack();

    // Initialize the IP
    ctx^.ExecutionState.IP:= 0;

    // Set not running initially
    ctx^.ExecutionState.Running:= false;

    // Initialize the sections
    ctx^.Sections.TypeSection:= nil;
    ctx^.Sections.FunctionSection:= nil;
    ctx^.Sections.ExportSection:= nil;
    ctx^.Sections.CodeSection:= nil;

    newContext:= ctx;
end;

function parse(buffer: puint8; buffer_end: puint8): PWASMProcessContext;
var
   ctx : PWASMProcessContext;
   pos : puint8;
   bytesRead : uint8;
   section_id : uint8;
   section_length : uint32;

begin
    // Allocate the context
    ctx:= newContext();
    pos:= buffer;

    writestringln('[wasm.parser] Parsing WASM Binary');

    // Check for the WASM Magic
    if(puint32(pos)^ = wasm.types.WASM_HDR_MAGIC) then begin
        writestringln('[wasm.parser] Binary is valid.');

        // Set binary to valid
        ctx^.ValidBinary:= true;
        inc(pos, 4);

        // Read the version
        ctx^.Version:= puint32(pos)^;
        inc(pos, 4);
        writestring('[wasm.parser] Version: ');
        writeintlnWND(ctx^.Version, 0);

        // Read the sections
        while (pos < buffer_end) do begin
            // Read the section id
            section_id:= pos^;
            inc(pos);

            // Read the section length
            bytesRead:= read_leb128_to_uint32(pos, buffer_end, @section_length);
            Inc(pos, bytesRead);

            // Handle the section
            wasm.parser.sections.handle(section_id, pos, section_length, ctx);

            // Move to the next section
            Inc(pos, section_length);
        end;
    end else begin
        writeln('[wasm.parser] Binary missing WASM Magic!');
        ctx^.ValidBinary:= false;
    end;
    parse:= ctx;
end;

end.

