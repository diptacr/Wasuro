unit wasm.parser.sections.exportSection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   currentEntry : PWASMExportEntry;
   i : uint32;

begin
    // Walk the export entries
    for i:=1 to ctx^.Sections.ExportSection^.ExportCount do begin
        currentEntry:= @ctx^.Sections.ExportSection^.Entries[i - 1];
        writestring('[wasm.parser]     Export: ');
        writestring(currentEntry^.Name);
        writestring(' - Type: ');
        writestring(GetWasmExportTypeString(currentEntry^.ExportType));
        writestring(' - Index: ');
        writeintlnWND(currentEntry^.FunctionIndex, 0);
    end;
end;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
var
   pos, bend : puint8;
   bytesRead : uint8;
   currentEntry : PWASMExportEntry;
   i,j : uint32;

begin
    writestring('[wasm.parser] Handle Section: Export - Size: ');
    writeintlnWND(section_length, 0);

    // Initialize the read/end pointers
    pos:= buffer;
    bend:= puint8(pos + section_length);

    // Initialize the export section
    ctx^.Sections.ExportSection:= PWASMExportSection(kalloc(sizeof(TWASMExportSection)));

    // Read the number of functions
    bytesRead:= read_leb128_to_uint32(pos, bend, @ctx^.Sections.ExportSection^.ExportCount);
    inc(pos, bytesRead);

    // Read the export entries
    if(ctx^.Sections.ExportSection^.ExportCount > 0) then begin
        // Allocate the first export entry
        ctx^.Sections.ExportSection^.Entries:= PWASMExportEntry(kalloc(sizeof(TWASMExportEntry) * ctx^.Sections.ExportSection^.ExportCount));

        // Read the export entries
        for i:=1 to ctx^.Sections.ExportSection^.ExportCount do begin

            // set the current entry
            currentEntry:= @ctx^.Sections.ExportSection^.Entries[i - 1];

            // Check if we are at the end of the buffer
            if pos >= bend then Exit;

            // Read the name length
            bytesRead:= read_leb128_to_uint32(pos, bend, @currentEntry^.NameLength);
            inc(pos, bytesRead);

            // Read the export name
            currentEntry^.Name:= pchar(kalloc(currentEntry^.NameLength + 1));
            for j:=0 to currentEntry^.NameLength - 1 do begin
                currentEntry^.Name[j]:= char(pos^);
                inc(pos);
            end;
            currentEntry^.Name[currentEntry^.NameLength]:= char($00);

            // Read the export type
            currentEntry^.ExportType:= TWasmExportType(pos^);
            inc(pos);

            // Read the export index
            bytesRead:= read_leb128_to_uint32(pos, bend, @currentEntry^.FunctionIndex);
            inc(pos, bytesRead);
        end;
    end;

    walk(ctx);
end;

end.
