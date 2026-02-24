unit wasm.parser.sections.customSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
begin
    {$IFDEF DEBUG_OUTPUT}
     console.writestring('[wasm.parser] Handle Section: Custom - Size: ');
     console.writeintlnWND(section_length, 0);
    {$ENDIF}
    { Custom sections are ignored in this implementation }
    console.writestringln('[wasm.parser] TODO: Custom section skipped.');
end;

end.