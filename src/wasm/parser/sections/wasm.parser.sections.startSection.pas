unit wasm.parser.sections.startSection;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.vm.io, wasm.types.leb128,
    wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   bytesRead : TWASMUInt8;
   funcIdx : TWASMUInt32;

begin
    {$IFDEF DEBUG_OUTPUT}
     wasm.vm.io.writestring('[wasm.parser] Handle Section: Start - Size: ');
     wasm.vm.io.writeintlnWND(section_length, 0);
    {$ENDIF}

    { Read the start function index }
    bytesRead := read_leb128_to_uint32(buffer, TWASMPUInt8(buffer + section_length), @funcIdx);
    ctx^.Sections.StartIndex := TWASMInt32(funcIdx);

    {$IFDEF DEBUG_OUTPUT}
     wasm.vm.io.writestring('[wasm.parser]     Start Function Index: ');
     wasm.vm.io.writeintlnWND(funcIdx, 0);
    {$ENDIF}
end;

end.