unit wasm.parser.sections.tableSection;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.vm.io, wasm.types.leb128,
    wasm.types.sections, wasm.types.context;

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);

implementation

procedure handle(buffer: TWASMPUInt8; section_length: TWASMUInt32; ctx: PWASMProcessContext);
var
    pos: TWASMPUInt8;
    buf_end: TWASMPUInt8;
    bytesRead: TWASMUInt8;
    table_count, i, j, min_size, max_size: TWASMUInt32;
    elem_type, limits_flag: TWASMUInt8;
    tables: PWASMTables;
begin
    {$IFDEF DEBUG_OUTPUT}
    wasm.vm.io.writestring('[wasm.parser] Handle Section: Table - Size: ');
    wasm.vm.io.writeintlnWND(section_length, 0);
    {$ENDIF}

    pos := buffer;
    buf_end := buffer;
    Inc(buf_end, section_length);

    bytesRead := read_leb128_to_uint32(pos, buf_end, @table_count);
    Inc(pos, bytesRead);

    {$IFDEF DEBUG_OUTPUT}
    writestring('[wasm.parser]     Tables: ');
    writeintlnWND(table_count, 0);
    {$ENDIF}

    tables := ctx^.ExecutionState.Tables;
    tables^.TableCount := table_count;
    if table_count > 0 then
        tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance) * table_count))
    else
        tables^.Tables := nil;

    for i := 0 to table_count - 1 do begin
        elem_type := pos^;
        Inc(pos);

        limits_flag := pos^;
        Inc(pos);

        bytesRead := read_leb128_to_uint32(pos, buf_end, @min_size);
        Inc(pos, bytesRead);

        max_size := 0;
        if limits_flag = 1 then begin
            bytesRead := read_leb128_to_uint32(pos, buf_end, @max_size);
            Inc(pos, bytesRead);
        end;

        {$IFDEF DEBUG_OUTPUT}
        wasm.vm.io.writestring('[wasm.parser]     Table ');
        wasm.vm.io.writeintWND(i, 0);
        wasm.vm.io.writestring(' - ElemType: $');
        wasm.vm.io.writeintWND(elem_type, 0);
        wasm.vm.io.writestring(' Initial: ');
        wasm.vm.io.writeintWND(min_size, 0);
        if limits_flag = 1 then begin
            wasm.vm.io.writestring(' Max: ');
            wasm.vm.io.writeintWND(max_size, 0);
        end;
        wasm.vm.io.writestringln('');
        {$ENDIF}

        tables^.Tables[i].ElementType := elem_type;
        tables^.Tables[i].Size := min_size;
        tables^.Tables[i].HasMax := (limits_flag = 1);
        if limits_flag = 1 then
            tables^.Tables[i].MaxSize := max_size
        else
            tables^.Tables[i].MaxSize := 0;

        { Allocate elements and initialize to $FFFFFFFF (uninitialized) }
        if min_size > 0 then begin
            tables^.Tables[i].Elements := TWASMPUInt32(kalloc(sizeof(TWASMUInt32) * min_size));
            for j := 0 to min_size - 1 do
                tables^.Tables[i].Elements[j] := $FFFFFFFF;
        end else
            tables^.Tables[i].Elements := nil;
    end;
end;

end.