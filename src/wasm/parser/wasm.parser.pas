unit wasm.parser;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.vm.io, wasm.types.leb128,
    wasm.types.enums, wasm.types.sections, wasm.types.context, wasm.types.heap, wasm.types.stack,
    wasm.parser.sections, wasm.types.constants;

function parse(buffer: TWASMPUInt8; buffer_end: TWASMPUInt8) : PWASMProcessContext;

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
    ctx^.Sections.ImportSection:= nil;
    ctx^.Sections.FunctionSection:= nil;
    ctx^.Sections.ExportSection:= nil;
    ctx^.Sections.CodeSection:= nil;
    ctx^.Sections.MemorySection:= nil;
    ctx^.Sections.StartIndex:= -1;

    // Initialize globals (empty until global section is parsed)
    ctx^.ExecutionState.Globals:= PWASMGlobals(kalloc(sizeof(TWASMGlobals)));
    ctx^.ExecutionState.Globals^.GlobalCount:= 0;
    ctx^.ExecutionState.Globals^.Globals:= nil;

    // Initialize tables (empty until table section is parsed)
    ctx^.ExecutionState.Tables:= PWASMTables(kalloc(sizeof(TWASMTables)));
    ctx^.ExecutionState.Tables^.TableCount:= 0;
    ctx^.ExecutionState.Tables^.Tables:= nil;

    // Initialize data segments (empty until data section is parsed)
    ctx^.ExecutionState.DataSegments:= PWASMDataSegments(kalloc(sizeof(TWASMDataSegments)));
    ctx^.ExecutionState.DataSegments^.SegmentCount:= 0;
    ctx^.ExecutionState.DataSegments^.Segments:= nil;

    // Initialize element segments (empty until element section is parsed)
    ctx^.ExecutionState.ElementSegments:= PWASMElementSegments(kalloc(sizeof(TWASMElementSegments)));
    ctx^.ExecutionState.ElementSegments^.SegmentCount:= 0;
    ctx^.ExecutionState.ElementSegments^.Segments:= nil;

    // Initialize WASI/import support
    ctx^.ExitCode := 0;
    ctx^.ResolvedImports.Count := 0;
    ctx^.ResolvedImports.Imports := nil;

    // Initialize WASI hooks (all nil)
    ctx^.WASIHooks.OnFdWrite := nil;
    ctx^.WASIHooks.OnFdRead := nil;
    ctx^.WASIHooks.OnFdClose := nil;
    ctx^.WASIHooks.OnFdSeek := nil;
    ctx^.WASIHooks.OnProcExit := nil;
    ctx^.WASIHooks.OnClockTimeGet := nil;
    ctx^.WASIHooks.OnClockResGet := nil;
    ctx^.WASIHooks.OnRandomGet := nil;
    ctx^.WASIHooks.OnArgsSizesGet := nil;
    ctx^.WASIHooks.OnArgsGet := nil;
    ctx^.WASIHooks.OnEnvironSizesGet := nil;
    ctx^.WASIHooks.OnEnvironGet := nil;

    // Initialize host function registry (empty, lazy-init on first register)
    ctx^.HostFuncRegistry.Count := 0;
    ctx^.HostFuncRegistry.Capacity := 0;
    ctx^.HostFuncRegistry.Entries := nil;

    newContext:= ctx;
end;

function parse(buffer: TWASMPUInt8; buffer_end: TWASMPUInt8): PWASMProcessContext;
var
   ctx : PWASMProcessContext;
   pos : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   section_id : TWASMUInt8;
   section_length : TWASMUInt32;

begin
    // Allocate the context
    ctx:= newContext();
    pos:= buffer;

    {$IFDEF DEBUG_OUTPUT}
     wasm.vm.io.writestringln('[wasm.parser] Starting parse of WASM binary.');
    {$ENDIF}

    // Check for the WASM Magic
    if(TWASMPUInt32(pos)^ = wasm.types.constants.WASM_HDR_MAGIC) then begin   
        {$IFDEF DEBUG_OUTPUT}
         wasm.vm.io.writestringln('[wasm.parser] Binary is valid.');
        {$ENDIF}

        // Set binary to valid
        ctx^.ValidBinary:= true;
        inc(pos, 4);

        // Read the version
        ctx^.Version:= TWASMPUInt32(pos)^;
        inc(pos, 4);
        {$IFDEF DEBUG_OUTPUT}
         wasm.vm.io.writestring('[wasm.parser] Version: ');
         wasm.vm.io.writeintlnWND(ctx^.Version, 0);
        {$ENDIF}

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
        wasm.vm.io.writestringln('[wasm.parser] Binary missing WASM Magic!');
        ctx^.ValidBinary:= false;
    end;
    parse:= ctx;
end;

end.

