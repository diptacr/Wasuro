unit wasm.parser.sections.typeSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, wasm.types.leb128,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   currentType : PWASMType;
   currentParam : PWASMParam;
   i,j : TWASMUInt32;

begin
     // Walk the wasm.types.builtin
     for i:=1 to ctx^.Sections.TypeSection^.TypeCount do begin
          currentType:= @ctx^.Sections.TypeSection^.Types[i - 1];
          writestring('[wasm.parser]     Index: ');
          writeintWND(i-1, 0);
          writestring(' - Function Type: ');
          writehexpair(currentType^._type);
          writestringln(' ');

          writestring('[wasm.parser]          Param Count: ');
          writeintlnWND(currentType^.ParamCount, 0);
          // Walk the parameters
          if(currentType^.ParamCount > 0) then begin
               for j:=1 to currentType^.ParamCount do begin
                    currentParam:= @currentType^.ParamTypes[j - 1];
                    writestring('[wasm.parser]               Param Type: ');
                    writestringln(GetWasmValueTypeString(currentParam^.ValueType));
               end;
          end;

          // Walk the return values
          writestring('[wasm.parser]          Return Count: ');
          writeintlnWND(currentType^.ReturnCount, 0);
          if(currentType^.ReturnCount > 0) then begin
               for j:=1 to currentType^.ReturnCount do begin
                    currentParam:= @currentType^.ReturnTypes[j - 1];
                    writestring('[wasm.parser]               Return Type: ');
                    writestringln(GetWasmValueTypeString(currentParam^.ValueType));
               end;
          end;
     end;
end;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   pos : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   currentType : PWASMType;
   currentParam : PWASMParam;
   i, parsedTypes : TWASMUInt32;

begin
     
     {$IFDEF DEBUG_OUTPUT}
     console.writestring('[wasm.parser] Handle Section: Type - Size: ');
     console.writeintlnWND(section_length, 0);
     {$ENDIF}
     pos:= buffer;

     // Initialize the type section
     ctx^.Sections.TypeSection:= PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
     ctx^.Sections.TypeSection^.TypeCount:= 0;

     // Read the number of function wasm.types.builtin
     bytesRead:= read_leb128_to_uint32(buffer, TWASMPUInt8(buffer + section_length), @ctx^.Sections.TypeSection^.TypeCount);
     inc(pos, bytesRead);

     // Read the function wasm.types.builtin
     if(ctx^.Sections.TypeSection^.TypeCount > 0) then begin
          // Allocate the first type
          ctx^.Sections.TypeSection^.Types:= PWASMType(kalloc(sizeof(TWASMType) * ctx^.Sections.TypeSection^.TypeCount));

          // Read the function wasm.types.builtin
          for parsedTypes:=1 to ctx^.Sections.TypeSection^.TypeCount do begin
               currentType:= @ctx^.Sections.TypeSection^.Types[parsedTypes - 1];

               // Check if we are at the end of the buffer
               if pos >= TWASMPUInt8(buffer + section_length) then Exit;

               // Read the function type
               currentType^._type:= pos^;
               inc(pos);

               // Read the number of parameters
               bytesRead:= read_leb128_to_uint32(pos, TWASMPUInt8(buffer + section_length), @currentType^.ParamCount);
               inc(pos, bytesRead);

               // Read the parameter wasm.types.builtin
               if(currentType^.ParamCount > 0) then begin
                    currentType^.ParamTypes:= PWASMParam(kalloc(sizeof(TWASMParam) * currentType^.ParamCount));
                    for i:=1 to currentType^.ParamCount do begin
                         currentParam:= @currentType^.ParamTypes[i - 1];
                         currentParam^.ValueType:= TWasmValueType(pos^);
                         inc(pos);
                    end;
               end;

               // Read the number of return values
               bytesRead:= read_leb128_to_uint32(pos, TWASMPUInt8(buffer + section_length), @currentType^.ReturnCount);
               inc(pos, bytesRead);

               // Read the return wasm.types.builtin
               if(currentType^.ReturnCount > 0) then begin
                    currentType^.ReturnTypes:= PWASMParam(kalloc(sizeof(TWASMParam) * currentType^.ReturnCount));
                    for i:=1 to currentType^.ReturnCount do begin
                         currentParam:= @currentType^.ReturnTypes[i - 1];
                         currentParam^.ValueType:= TWasmValueType(pos^);
                         inc(pos);
                    end;
               end;
          end;
     end;

     // Walk the wasm.types.builtin
     {$IFDEF DEBUG_OUTPUT}
     walk(ctx);
     {$ENDIF}
end;

end.
