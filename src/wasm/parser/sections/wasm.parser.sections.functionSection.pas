unit wasm.parser.sections.functionSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   currentFunc : PWASMFunction;
   i : TWASMUInt32;

begin
    // Walk the functions
    for i:=1 to ctx^.Sections.FunctionSection^.FunctionCount do begin
        currentFunc:= @ctx^.Sections.FunctionSection^.Functions[i - 1];
        writestring('[wasm.parser]     Function: ');
        writeintlnWND(currentFunc^.Index, 0);
    end;
end;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   currentFunc : PWASMFunction;
   i : TWASMUInt32;

begin
    writestring('[wasm.parser] Handle Section: Function - Size: ');
    writeintlnWND(section_length, 0);

    // Initialize the read/end pointers
    pos:= buffer;
    bend:= TWASMPUInt8(pos + section_length);

    // Initialize the function section
    ctx^.Sections.FunctionSection:= PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount:= 0;
    ctx^.Sections.FunctionSection^.Functions:= nil;

    // Read the number of functions
    bytesRead:= read_leb128_to_uint32(pos, bend, @ctx^.Sections.FunctionSection^.FunctionCount);
    inc(pos, bytesRead);

    // Read the functions
    if ctx^.Sections.FunctionSection^.FunctionCount > 0 then begin
        // Bounds check
        if pos >= bend then Exit;

        // Allocate the first function
        ctx^.Sections.FunctionSection^.Functions:= PWASMFunction(kalloc(sizeof(TWASMFunction) * ctx^.Sections.FunctionSection^.FunctionCount));

        // Read the functions
        for i:=1 to ctx^.Sections.FunctionSection^.FunctionCount do begin
            currentFunc:= @ctx^.Sections.FunctionSection^.Functions[i - 1];
            if pos >= bend then Exit;
            bytesRead:= read_leb128_to_uint32(pos, bend, @currentFunc^.Index);
            inc(pos, bytesRead);
        end;
    end;
    
    walk(ctx);
end;

end.
