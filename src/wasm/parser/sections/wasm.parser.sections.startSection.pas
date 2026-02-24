unit wasm.parser.sections.startSection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
var
   bytesRead : uint8;
   funcIdx : uint32;

begin
    writestring('[wasm.parser] Handle Section: Start - Size: ');
    writeintlnWND(section_length, 0);

    { Read the start function index }
    bytesRead := read_leb128_to_uint32(buffer, puint8(buffer + section_length), @funcIdx);
    ctx^.Sections.StartIndex := int32(funcIdx);

    writestring('[wasm.parser]     Start Function Index: ');
    writeintlnWND(funcIdx, 0);
end;

end.