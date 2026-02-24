unit wasm.parser.sections.tableSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
begin
    writestring('[wasm.parser] Handle Section: Table - Size: ');
    writeintlnWND(section_length, 0);
end;

end.