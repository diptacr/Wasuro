unit wasm.test.parser.passivedata;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.types.heap, wasm.test.framework,
    wasm.parser.sections.dataSection, lmemorymanager;

procedure run;
var
    buf : array[0..24] of TWASMUInt8;
    ctx : PWASMProcessContext;
    val : TWASMUInt8;
begin
    test_begin('parser.data.passive');

    { Test mode 0 (active): data copied to memory AND stored in DataSegments }
    { Binary: [$02, $00, $41, $05, $0B, $02, $AA, $BB, $01, $02, $CC, $DD]
      $02 = 2 segments
      --- Segment 0 (mode 0): ---
      $00 = mode 0 (active, memory 0)
      $41 = i32.const, $05 = offset 5, $0B = end
      $02 = 2 data bytes
      $AA, $BB = data
      --- Segment 1 (mode 1): ---
      $01 = mode 1 (passive)
      $02 = 2 data bytes
      $CC, $DD = data }
    buf[0] := $02;  { segment_count = 2 }
    { Segment 0: mode 0 active }
    buf[1] := $00;  { mode 0 }
    buf[2] := $41;  { i32.const }
    buf[3] := $05;  { offset = 5 }
    buf[4] := $0B;  { end }
    buf[5] := $02;  { data_len = 2 }
    buf[6] := $AA;  { data byte 0 }
    buf[7] := $BB;  { data byte 1 }
    { Segment 1: mode 1 passive }
    buf[8] := $01;  { mode 1 }
    buf[9] := $02;  { data_len = 2 }
    buf[10] := $CC; { data byte 0 }
    buf[11] := $DD; { data byte 1 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.dataSection.handle(@buf[0], 12, ctx);

    { Active segment: data written to memory }
    read_uint8(5, ctx^.ExecutionState.Memory, @val);
    assert_u32('active mem[5]=$AA', TWASMUInt32(val), $AA);
    read_uint8(6, ctx^.ExecutionState.Memory, @val);
    assert_u32('active mem[6]=$BB', TWASMUInt32(val), $BB);

    { Active segment: stored in DataSegments AND marked dropped }
    assert_u32('seg_count=2', ctx^.ExecutionState.DataSegments^.SegmentCount, 2);
    assert_true('seg0 dropped', ctx^.ExecutionState.DataSegments^.Segments[0].Dropped);
    assert_u32('seg0 size=2', ctx^.ExecutionState.DataSegments^.Segments[0].Size, 2);

    { Passive segment: NOT written to memory, stored in DataSegments, NOT dropped }
    assert_true('seg1 not dropped', not ctx^.ExecutionState.DataSegments^.Segments[1].Dropped);
    assert_u32('seg1 size=2', ctx^.ExecutionState.DataSegments^.Segments[1].Size, 2);
    assert_u32('seg1 data[0]=$CC', TWASMUInt32(ctx^.ExecutionState.DataSegments^.Segments[1].Data[0]), $CC);
    assert_u32('seg1 data[1]=$DD', TWASMUInt32(ctx^.ExecutionState.DataSegments^.Segments[1].Data[1]), $DD);

    { Test mode 2 (active with explicit memory index) }
    buf[0] := $01;  { segment_count = 1 }
    buf[1] := $02;  { mode 2 }
    buf[2] := $00;  { memory index = 0 }
    buf[3] := $41;  { i32.const }
    buf[4] := $0A;  { offset = 10 }
    buf[5] := $0B;  { end }
    buf[6] := $02;  { data_len = 2 }
    buf[7] := $EE;  { data byte 0 }
    buf[8] := $FF;  { data byte 1 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.dataSection.handle(@buf[0], 9, ctx);

    read_uint8(10, ctx^.ExecutionState.Memory, @val);
    assert_u32('mode2 mem[10]=$EE', TWASMUInt32(val), $EE);
    read_uint8(11, ctx^.ExecutionState.Memory, @val);
    assert_u32('mode2 mem[11]=$FF', TWASMUInt32(val), $FF);
    assert_true('mode2 seg dropped', ctx^.ExecutionState.DataSegments^.Segments[0].Dropped);

    test_end;
end;

end.
