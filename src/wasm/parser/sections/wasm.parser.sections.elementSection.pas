unit wasm.parser.sections.elementSection;

interface

uses
    wasm.types.builtin, lmemorymanager, console, leb128,
    wasm.types.sections, wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
    pos: TWASMPUInt8;
    buf_end: TWASMPUInt8;
    bytesRead: TWASMUInt8;
    seg_count, i, j: TWASMUInt32;
    mode: TWASMUInt32;
    offset, func_count, func_idx: TWASMUInt32;
    elem_kind : TWASMUInt8;
    opcode: TWASMUInt8;
    tables: PWASMTables;
    indices: TWASMPUInt32;
begin
    writestring('[wasm.parser] Handle Section: Element - Size: ');
    writeintlnWND(section_length, 0);

    pos := buffer;
    buf_end := buffer;
    Inc(buf_end, section_length);

    bytesRead := read_leb128_to_uint32(pos, buf_end, @seg_count);
    Inc(pos, bytesRead);

    writestring('[wasm.parser]     Element Segments: ');
    writeintlnWND(seg_count, 0);

    tables := ctx^.ExecutionState.Tables;

    { Allocate element segments storage }
    ctx^.ExecutionState.ElementSegments^.SegmentCount := seg_count;
    if seg_count > 0 then
        ctx^.ExecutionState.ElementSegments^.Segments := PWASMElementSegment(kalloc(seg_count * sizeof(TWASMElementSegment)))
    else
        ctx^.ExecutionState.ElementSegments^.Segments := nil;

    for i := 0 to seg_count - 1 do begin
        bytesRead := read_leb128_to_uint32(pos, buf_end, @mode);
        Inc(pos, bytesRead);

        { Initialize defaults }
        ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex := 0;
        ctx^.ExecutionState.ElementSegments^.Segments[i].Offset := 0;
        ctx^.ExecutionState.ElementSegments^.Segments[i].FuncCount := 0;
        ctx^.ExecutionState.ElementSegments^.Segments[i].FuncIndices := nil;
        ctx^.ExecutionState.ElementSegments^.Segments[i].Dropped := false;

        if mode = 0 then begin
            { Mode 0: active segment, implicit table 0, i32 offset expression }
            opcode := pos^;
            Inc(pos);

            offset := 0;
            if opcode = $41 then begin { i32.const }
                bytesRead := read_leb128_to_uint32(pos, buf_end, @offset);
                Inc(pos, bytesRead);
            end;

            { Skip 'end' opcode ($0B) }
            if pos^ = $0B then
                Inc(pos);

            { Read function index vector }
            bytesRead := read_leb128_to_uint32(pos, buf_end, @func_count);
            Inc(pos, bytesRead);

            writestring('[wasm.parser]     Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 0 Offset: ');
            writeintWND(offset, 0);
            writestring(' Functions: ');
            writeintlnWND(func_count, 0);

            { Store segment data }
            indices := TWASMPUInt32(kalloc(func_count * sizeof(TWASMUInt32)));
            for j := 0 to func_count - 1 do begin
                bytesRead := read_leb128_to_uint32(pos, buf_end, @func_idx);
                Inc(pos, bytesRead);
                indices[j] := func_idx;
            end;

            ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex := 0;
            ctx^.ExecutionState.ElementSegments^.Segments[i].Offset := offset;
            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncCount := func_count;
            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncIndices := indices;
            ctx^.ExecutionState.ElementSegments^.Segments[i].Dropped := true; { active = dropped after init }

            { Write function indices into the table }
            if (tables^.TableCount > 0) then begin
                for j := 0 to func_count - 1 do begin
                    if (offset + j) < tables^.Tables[0].Size then
                        tables^.Tables[0].Elements[offset + j] := indices[j];
                end;
            end;

        end else if mode = 1 then begin
            { Mode 1: passive segment with element kind byte }
            elem_kind := pos^;
            Inc(pos);

            bytesRead := read_leb128_to_uint32(pos, buf_end, @func_count);
            Inc(pos, bytesRead);

            writestring('[wasm.parser]     Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 1 (passive) Kind: ');
            writeintWND(elem_kind, 0);
            writestring(' Functions: ');
            writeintlnWND(func_count, 0);

            indices := TWASMPUInt32(kalloc(func_count * sizeof(TWASMUInt32)));
            for j := 0 to func_count - 1 do begin
                bytesRead := read_leb128_to_uint32(pos, buf_end, @func_idx);
                Inc(pos, bytesRead);
                indices[j] := func_idx;
            end;

            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncCount := func_count;
            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncIndices := indices;
            ctx^.ExecutionState.ElementSegments^.Segments[i].Dropped := false; { passive = available }

        end else if mode = 2 then begin
            { Mode 2: active with explicit table index }
            bytesRead := read_leb128_to_uint32(pos, buf_end, @func_idx);
            Inc(pos, bytesRead);
            ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex := func_idx;

            opcode := pos^;
            Inc(pos);
            offset := 0;
            if opcode = $41 then begin
                bytesRead := read_leb128_to_uint32(pos, buf_end, @offset);
                Inc(pos, bytesRead);
            end;
            if pos^ = $0B then
                Inc(pos);

            { Element kind byte }
            elem_kind := pos^;
            Inc(pos);

            bytesRead := read_leb128_to_uint32(pos, buf_end, @func_count);
            Inc(pos, bytesRead);

            writestring('[wasm.parser]     Segment ');
            writeintWND(i, 0);
            writestring(' - Mode: 2 Table: ');
            writeintWND(ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex, 0);
            writestring(' Offset: ');
            writeintWND(offset, 0);
            writestring(' Functions: ');
            writeintlnWND(func_count, 0);

            indices := TWASMPUInt32(kalloc(func_count * sizeof(TWASMUInt32)));
            for j := 0 to func_count - 1 do begin
                bytesRead := read_leb128_to_uint32(pos, buf_end, @func_idx);
                Inc(pos, bytesRead);
                indices[j] := func_idx;
            end;

            ctx^.ExecutionState.ElementSegments^.Segments[i].Offset := offset;
            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncCount := func_count;
            ctx^.ExecutionState.ElementSegments^.Segments[i].FuncIndices := indices;
            ctx^.ExecutionState.ElementSegments^.Segments[i].Dropped := true;

            { Write to table }
            if (ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex < tables^.TableCount) then begin
                for j := 0 to func_count - 1 do begin
                    if (offset + j) < tables^.Tables[ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex].Size then
                        tables^.Tables[ctx^.ExecutionState.ElementSegments^.Segments[i].TableIndex].Elements[offset + j] := indices[j];
                end;
            end;

        end else begin
            writestring('[wasm.parser]     Skipping element segment mode: ');
            writeintlnWND(mode, 0);
            break;
        end;
    end;
end;

end.