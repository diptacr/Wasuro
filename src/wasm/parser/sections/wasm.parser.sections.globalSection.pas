unit wasm.parser.sections.globalSection;

interface

uses
    types, lmemorymanager, console, leb128,
    wasm.types;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);

implementation

procedure walk(ctx : PWASMProcessContext);
var
   i : uint32;
   entry : PWASMGlobalEntry;
begin
    for i := 0 to ctx^.ExecutionState.Globals^.GlobalCount - 1 do begin
        entry := @ctx^.ExecutionState.Globals^.Globals[i];
        writestring('[wasm.parser]     Global ');
        writeintWND(i, 0);
        writestring(' - Type: ');
        writestring(GetWasmValueTypeString(entry^.ValueType));
        if entry^.Mutable then
           writestring(' (mut)')
        else
           writestring(' (const)');
        writestring(' = ');
        case entry^.ValueType of
            vti32: writeintlnWND(entry^.Value.i32Value, 0);
            vti64: writeintlnWND(entry^.Value.i64Value, 0);
        else
            writestringln('<value>');
        end;
    end;
end;

procedure handle(buffer: puint8; section_length: uint32; ctx: PWASMProcessContext);
var
   pos, bend : puint8;
   bytesRead : uint8;
   globalCount : uint32;
   i : uint32;
   entry : PWASMGlobalEntry;
   valType : uint8;
   mutFlag : uint8;
   opcode : uint8;
   tmpU32 : uint32;
   tmpU64 : uint64;

begin
    writestring('[wasm.parser] Handle Section: Global - Size: ');
    writeintlnWND(section_length, 0);

    pos := buffer;
    bend := puint8(buffer + section_length);

    { Read global count }
    bytesRead := read_leb128_to_uint32(pos, bend, @globalCount);
    Inc(pos, bytesRead);

    { Allocate globals on ExecutionState }
    ctx^.ExecutionState.Globals := PWASMGlobals(kalloc(sizeof(TWASMGlobals)));
    ctx^.ExecutionState.Globals^.GlobalCount := globalCount;
    ctx^.ExecutionState.Globals^.Globals := PWASMGlobalEntry(kalloc(sizeof(TWASMGlobalEntry) * globalCount));

    for i := 0 to globalCount - 1 do begin
        entry := @ctx^.ExecutionState.Globals^.Globals[i];

        { Read value type }
        valType := pos^;
        Inc(pos);
        entry^.ValueType := TWasmValueType(valType);

        { Read mutability }
        mutFlag := pos^;
        Inc(pos);
        entry^.Mutable := (mutFlag = 1);

        { Initialize value to zero }
        entry^.Value.i64Value := 0;
        entry^.Value.ValueType := entry^.ValueType;

        { Evaluate constant init expression }
        opcode := pos^;
        Inc(pos);
        case opcode of
            $41: begin { i32.const }
                bytesRead := read_leb128_to_uint32(pos, bend, @tmpU32);
                Inc(pos, bytesRead);
                entry^.Value.i32Value := int32(tmpU32);
            end;
            $42: begin { i64.const }
                bytesRead := read_leb128_to_uint64(pos, bend, @tmpU64);
                Inc(pos, bytesRead);
                entry^.Value.i64Value := int64(tmpU64);
            end;
            $43: begin { f32.const }
                entry^.Value.f32Value := pfloat(pos)^;
                Inc(pos, 4);
            end;
            $44: begin { f64.const }
                entry^.Value.f64Value := pdouble(pos)^;
                Inc(pos, 8);
            end;
        else
            writestring('[wasm.parser] Warning: unsupported global init opcode: ');
            writehexpair(opcode);
            writestringln(' ');
            { Skip to end opcode }
            while (pos < bend) and (pos^ <> $0B) do Inc(pos);
        end;

        { Consume the end ($0B) opcode }
        if (pos < bend) and (pos^ = $0B) then
            Inc(pos);
    end;

    walk(ctx);
end;

end.