unit wasm.parser.sections.codeSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure printCtxCode(ctx : PWASMProcessContext);
var
    i : TWASMUInt32;

begin
    writestring('[wasm.parser]     Flat Code: ');
    for i:=1 to ctx^.ExecutionState.Limit do begin
        writehexpair(ctx^.ExecutionState.Code[i - 1]);
        writestring(' ');
    end;
    writestringln(' ');
end;

procedure walk(ctx : PWASMProcessContext);
var
   localpos, pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   currentEntry : PWASMCodeEntry;
   i,j,l : TWASMUInt32;
   localCount,localTemp,localIndex : TWASMUInt32;
   localType: TWasmValueType;
   codeLength: TWASMUInt32;
   codeOffset: TWASMUInt32;
   totalSize: TWASMUInt32;
begin
    // Walk the code entries
    for i:=1 to ctx^.Sections.CodeSection^.CodeCount do begin
        currentEntry:= @ctx^.Sections.CodeSection^.Entries[i - 1];
        writestring('[wasm.parser]     Code: ');
        writeintlnWND(i - 1, 0);
        writestring('[wasm.parser]         Section Length: ');
        writeintlnWND(currentEntry^.SectionLength, 0);
        writestring('[wasm.parser]         Code Length: ');
        writeintlnWND(currentEntry^.CodeLength, 0);
        writestring('[wasm.parser]         Locals: ');
        writeintlnWND(currentEntry^.Locals.TypeCount, 0);
        writestring('[wasm.parser]         CodeIndex: ');
        writeintlnWND(currentEntry^.CodeIndex, 0);
        for j:=1 to currentEntry^.Locals.TypeCount do begin
            writestring('[wasm.parser]             Local Type: ');
            writestring(GetWasmValueTypeString(currentEntry^.Locals.Locals[j - 1].ValueType));
            writestring(' - Value: ');
            writeintlnWND(currentEntry^.Locals.Locals[j - 1].i64Value, 0);
        end;
    end;
    printCtxCode(ctx);
end;


procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
   localpos, pos, bend : TWASMPUInt8;
   bytesRead : TWASMUInt8;
   currentEntry : PWASMCodeEntry;
   i,j,l : TWASMUInt32;
   localCount,localTemp,localIndex : TWASMUInt32;
   localType: TWasmValueType;
   codeLength: TWASMUInt32;
   codeOffset: TWASMUInt32;
   totalSize: TWASMUInt32;

begin
    writestring('[wasm.parser] Handle Section: Code - Size: ');
    writeintlnWND(section_length, 0);

    // Initialize the read/end pointers
    pos:= buffer;
    bend:= TWASMPUInt8(pos + section_length);

    // Initialize the code section
    ctx^.Sections.CodeSection:= PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));

    // Read the number of functions
    bytesRead:= read_leb128_to_uint32(pos, bend, @ctx^.Sections.CodeSection^.CodeCount);
    inc(pos, bytesRead);

    // Read the code entries
    if(ctx^.Sections.CodeSection^.CodeCount > 0) then begin
        // Allocate the first code entry
        ctx^.Sections.CodeSection^.Entries:= PWASMCodeEntry(kalloc(sizeof(TWASMCodeEntry) * ctx^.Sections.CodeSection^.CodeCount));

        // Read the code entries
        for i:=1 to ctx^.Sections.CodeSection^.CodeCount do begin
            currentEntry:= @ctx^.Sections.CodeSection^.Entries[i - 1];
            codeOffset:= 0;

            // Read the section length
            bytesRead:= read_leb128_to_uint32(pos, bend, @currentEntry^.SectionLength);
            inc(pos, bytesRead);

            // Read the local count
            bytesRead:= read_leb128_to_uint32(pos, bend, @currentEntry^.Locals.TypeCount);
            inc(pos, bytesRead);
            inc(codeOffset, bytesRead);

            // Read the locals
            if(currentEntry^.Locals.TypeCount > 0) then begin

                // Determine the actual number of locals
                localpos:= pos;
                localCount:= 0;
                for j:=1 to currentEntry^.Locals.TypeCount do begin
                    // Get the count of locals of this type
                    bytesRead:= read_leb128_to_uint32(localpos, bend, @localTemp);

                    // increment the total count of locals
                    inc(localCount, localTemp);

                    // Increment the temp buffer pointer by to next local count (skip the type)
                    inc(localpos, bytesRead + 1); // +1 to skip the type

                    // do the same for our codeOffset
                    inc(codeOffset, bytesRead + 1); // +1 to skip the type
                end;

                currentEntry^.Locals.LocalCount:= localCount;

                // Get the length of the actual code, this is the section, minus any bytes used for locals, and the local 
                currentEntry^.CodeLength:= currentEntry^.SectionLength - codeOffset;
                currentEntry^.CodeIndex:= 0;

                // Allocate the locals
                currentEntry^.Locals.Locals:= PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * localCount));
                localIndex:= 0;
                for j:=1 to currentEntry^.Locals.TypeCount do begin
                    // Read the count of locals of this type
                    bytesRead:= read_leb128_to_uint32(pos, bend, @localTemp);
                    inc(pos, bytesRead);

                    // Read the local type
                    localType:= TWasmValueType(pos^);
                    inc(pos);

                    // Initialize the locals
                    for l:=1 to localTemp do begin
                        currentEntry^.Locals.Locals[localIndex].ValueType:= localType;
                        currentEntry^.Locals.Locals[localIndex].i64Value:= 0;
                        inc(localIndex);
                    end;
                    
                end;
            end else begin
                currentEntry^.CodeLength:= currentEntry^.SectionLength - 1;
                currentEntry^.Locals.LocalCount:= 0;
                currentEntry^.Locals.Locals:= nil;
            end;

            // Read the code
            currentEntry^.Code:= TWASMPUInt8(kalloc(currentEntry^.CodeLength));
            for j:=1 to currentEntry^.CodeLength do begin
                currentEntry^.Code[j - 1]:= pos^;
                inc(pos);
            end;
        end;

        totalSize:= 0;
        for i:=1 to ctx^.Sections.CodeSection^.CodeCount do begin
            currentEntry:= @ctx^.Sections.CodeSection^.Entries[i - 1];
            totalSize:= totalSize + currentEntry^.CodeLength;
        end;

        ctx^.ExecutionState.Code:= TWASMPUInt8(kalloc(totalSize));
        ctx^.ExecutionState.Limit:= totalSize;
        localpos:= ctx^.ExecutionState.Code;
        for i:=1 to ctx^.Sections.CodeSection^.CodeCount do begin
            currentEntry:= @ctx^.Sections.CodeSection^.Entries[i - 1];
            currentEntry^.CodeIndex:= TWASMUInt32(localpos - ctx^.ExecutionState.Code);
            for j:=1 to currentEntry^.CodeLength do begin
                localpos^:= currentEntry^.Code[j - 1];
                inc(localpos);
            end;
        end;
    end;

    walk(ctx);
end;

end.
