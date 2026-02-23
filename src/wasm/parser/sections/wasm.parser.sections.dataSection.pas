unit wasm.parser.sections.dataSection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
begin
    writestring('[wasm.parser] Handle Section: Data - Size: ');
    writeintlnWND(section_length, 0);
end;

end.