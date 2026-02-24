unit wasm.test.opcode.memoryinit;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.heap, wasm.vm, wasm.test.framework,
    lmemorymanager;

procedure setup_data_segment(ctx : PWASMProcessContext; data : TWASMPUInt8; size : TWASMUInt32);
begin
    ctx^.ExecutionState.DataSegments^.SegmentCount := 1;
    ctx^.ExecutionState.DataSegments^.Segments := PWASMDataSegment(kalloc(sizeof(TWASMDataSegment)));
    ctx^.ExecutionState.DataSegments^.Segments[0].Data := data;
    ctx^.ExecutionState.DataSegments^.Segments[0].Size := size;
    ctx^.ExecutionState.DataSegments^.Segments[0].Dropped := false;
end;

procedure run;
var
    { FC $08, data_idx=0, mem_idx=0 }
    code : array[0..3] of TWASMUInt8;
    ctx : PWASMProcessContext;
    segData : array[0..3] of TWASMUInt8;
    b : TWASMUInt8;
begin
    test_begin('opcode.memory.init');

    code[0] := $FC; code[1] := $08; code[2] := $00; code[3] := $00;

    { Copy 4 bytes from data segment to memory at offset 10 }
    segData[0] := $AA; segData[1] := $BB; segData[2] := $CC; segData[3] := $DD;
    ctx := make_test_context(@code[0], 4);
    setup_data_segment(ctx, @segData[0], 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);  { d = 10 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 4);   { n = 4 }
    wasm.vm.tick(ctx);
    read_uint8(10, ctx^.ExecutionState.Memory, @b);
    assert_u32('mem[10]=$AA', b, $AA);
    read_uint8(11, ctx^.ExecutionState.Memory, @b);
    assert_u32('mem[11]=$BB', b, $BB);
    read_uint8(12, ctx^.ExecutionState.Memory, @b);
    assert_u32('mem[12]=$CC', b, $CC);
    read_uint8(13, ctx^.ExecutionState.Memory, @b);
    assert_u32('mem[13]=$DD', b, $DD);

    { Copy 2 bytes from offset 1 in data segment }
    ctx := make_test_context(@code[0], 4);
    setup_data_segment(ctx, @segData[0], 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { d = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { s = 1 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);   { n = 2 }
    wasm.vm.tick(ctx);
    read_uint8(0, ctx^.ExecutionState.Memory, @b);
    assert_u32('partial_mem[0]=$BB', b, $BB);
    read_uint8(1, ctx^.ExecutionState.Memory, @b);
    assert_u32('partial_mem[1]=$CC', b, $CC);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 4);
    setup_data_segment(ctx, @segData[0], 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { d }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { n = 0 }
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    { Out of bounds source traps }
    ctx := make_test_context(@code[0], 4);
    setup_data_segment(ctx, @segData[0], 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { d }
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);   { s = 2 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);   { n = 5, exceeds segment size }
    wasm.vm.tick(ctx);
    assert_true('oob_source traps', not ctx^.ExecutionState.Running);

    { Dropped segment traps }
    ctx := make_test_context(@code[0], 4);
    setup_data_segment(ctx, @segData[0], 4);
    ctx^.ExecutionState.DataSegments^.Segments[0].Dropped := true;
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_true('dropped traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
