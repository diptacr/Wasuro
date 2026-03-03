unit wasm.parser.sections.customSection;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.vm.io, wasm.types.leb128,
    wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
begin
    {$IFDEF DEBUG_OUTPUT}
     wasm.vm.io.writestring('[wasm.parser] Handle Section: Custom - Size: ');
     wasm.vm.io.writeintlnWND(section_length, 0);
    {$ENDIF}
    { Custom sections are ignored in this implementation }
    wasm.vm.io.writestringln('[wasm.parser] TODO: Custom section skipped.');
end;

end.