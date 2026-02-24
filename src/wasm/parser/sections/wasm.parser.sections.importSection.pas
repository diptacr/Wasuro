unit wasm.parser.sections.importSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types.enums, wasm.types.sections, wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   entry : PWASMImportEntry;
   i : TWASMUInt32;
begin
    for i := 1 to ctx^.Sections.ImportSection^.ImportCount do begin
        entry := @ctx^.Sections.ImportSection^.Entries[i - 1];
        writestring('[wasm.parser]     Import: ');
        writestring(entry^.ModuleName);
        writestring('.');
        writestring(entry^.FieldName);
        writestring(' - Kind: ');
        writestring(GetWasmImportDescKindString(TWasmImportDescKind(entry^.Desc.Kind)));
        case entry^.Desc.Kind of
          $00: begin
            writestring(' - TypeIndex: ');
            writeintlnWND(entry^.Desc.TypeIndex, 0);
          end;
          $01: begin
            writestring(' - ElemType: ');
            writeintWND(entry^.Desc.TableElemType, 0);
            writestring(' Min: ');
            writeintWND(entry^.Desc.LimitsMin, 0);
            if entry^.Desc.HasMax then begin
              writestring(' Max: ');
              writeintWND(entry^.Desc.LimitsMax, 0);
            end;
            writestringln('');
          end;
          $02: begin
            writestring(' - Min: ');
            writeintWND(entry^.Desc.LimitsMin, 0);
            if entry^.Desc.HasMax then begin
              writestring(' Max: ');
              writeintWND(entry^.Desc.LimitsMax, 0);
            end;
            writestringln('');
          end;
          $03: begin
            writestring(' - ValType: ');
            writestring(GetWasmValueTypeString(TWasmValueType(entry^.Desc.GlobalValType)));
            writestring(' Mutable: ');
            if entry^.Desc.GlobalMut then
              writestringln('yes')
            else
              writestringln('no');
          end;
        else
          writestringln('');
        end;
    end;
end;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   entry : PWASMImportEntry;
   i, j : TWASMUInt32;
   limitsFlag : TWASMUInt8;
begin
    writestring('[wasm.parser] Handle Section: Import - Size: ');
    writeintlnWND(section_length, 0);

    pos := buffer;
    bend := TWASMPUInt8(pos + section_length);

    { Allocate the import section }
    ctx^.Sections.ImportSection := PWASMImportSection(kalloc(sizeof(TWASMImportSection)));

    { Read the number of imports }
    bytesRead := read_leb128_to_uint32(pos, bend, @ctx^.Sections.ImportSection^.ImportCount);
    Inc(pos, bytesRead);

    writestring('[wasm.parser]     Import Count: ');
    writeintlnWND(ctx^.Sections.ImportSection^.ImportCount, 0);

    if ctx^.Sections.ImportSection^.ImportCount > 0 then begin
        { Allocate entries }
        ctx^.Sections.ImportSection^.Entries := PWASMImportEntry(
            kalloc(sizeof(TWASMImportEntry) * ctx^.Sections.ImportSection^.ImportCount));

        for i := 1 to ctx^.Sections.ImportSection^.ImportCount do begin
            entry := @ctx^.Sections.ImportSection^.Entries[i - 1];

            if pos >= bend then Exit;

            { Read module name }
            bytesRead := read_leb128_to_uint32(pos, bend, @entry^.ModuleNameLength);
            Inc(pos, bytesRead);

            entry^.ModuleName := TWASMPChar(kalloc(entry^.ModuleNameLength + 1));
            for j := 0 to entry^.ModuleNameLength - 1 do begin
                entry^.ModuleName[j] := TWASMChar(pos^);
                Inc(pos);
            end;
            entry^.ModuleName[entry^.ModuleNameLength] := TWASMChar($00);

            { Read field name }
            bytesRead := read_leb128_to_uint32(pos, bend, @entry^.FieldNameLength);
            Inc(pos, bytesRead);

            entry^.FieldName := TWASMPChar(kalloc(entry^.FieldNameLength + 1));
            for j := 0 to entry^.FieldNameLength - 1 do begin
                entry^.FieldName[j] := TWASMChar(pos^);
                Inc(pos);
            end;
            entry^.FieldName[entry^.FieldNameLength] := TWASMChar($00);

            { Read import descriptor kind }
            entry^.Desc.Kind := pos^;
            Inc(pos);

            case entry^.Desc.Kind of
              $00: begin
                { Function import: type index }
                bytesRead := read_leb128_to_uint32(pos, bend, @entry^.Desc.TypeIndex);
                Inc(pos, bytesRead);
              end;
              $01: begin
                { Table import: elem type + limits }
                entry^.Desc.TableElemType := pos^;
                Inc(pos);
                limitsFlag := pos^;
                Inc(pos);
                entry^.Desc.HasMax := (limitsFlag = 1);
                bytesRead := read_leb128_to_uint32(pos, bend, @entry^.Desc.LimitsMin);
                Inc(pos, bytesRead);
                if entry^.Desc.HasMax then begin
                    bytesRead := read_leb128_to_uint32(pos, bend, @entry^.Desc.LimitsMax);
                    Inc(pos, bytesRead);
                end;
              end;
              $02: begin
                { Memory import: limits }
                limitsFlag := pos^;
                Inc(pos);
                entry^.Desc.HasMax := (limitsFlag = 1);
                bytesRead := read_leb128_to_uint32(pos, bend, @entry^.Desc.LimitsMin);
                Inc(pos, bytesRead);
                if entry^.Desc.HasMax then begin
                    bytesRead := read_leb128_to_uint32(pos, bend, @entry^.Desc.LimitsMax);
                    Inc(pos, bytesRead);
                end;
              end;
              $03: begin
                { Global import: value type + mutability }
                entry^.Desc.GlobalValType := pos^;
                Inc(pos);
                entry^.Desc.GlobalMut := (pos^ <> 0);
                Inc(pos);
              end;
            end;
        end;
    end;

    walk(ctx);
end;

end.