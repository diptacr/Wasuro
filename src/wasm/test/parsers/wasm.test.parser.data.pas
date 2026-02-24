unit wasm.test.parser.data;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.context, wasm.types.heap, wasm.test.framework,
    wasm.parser.sections.dataSection;

procedure run;
var
    buf : array[0..9] of TWASMUInt8;
    ctx : PWASMProcessContext;
    val : TWASMUInt8;
begin
    test_begin('parser.data');

    { Build binary: 1 data segment at memory 0, offset 16, with 4 bytes
      Buffer: [$01, $00, $41, $10, $0B, $04, $DE, $AD, $BE, $EF]
      $01 = 1 segment
      $00 = memory_index = 0
      $41 = i32.const, $10 = 16, $0B = end
      $04 = data_len = 4
      $DE, $AD, $BE, $EF = data bytes }
    buf[0] := $01; { segment_count = 1 }
    buf[1] := $00; { memory_index = 0 }
    buf[2] := $41; { i32.const opcode }
    buf[3] := $10; { offset = 16 }
    buf[4] := $0B; { end }
    buf[5] := $04; { data_len = 4 }
    buf[6] := $DE; { data byte 0 }
    buf[7] := $AD; { data byte 1 }
    buf[8] := $BE; { data byte 2 }
    buf[9] := $EF; { data byte 3 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.dataSection.handle(@buf[0], 10, ctx);

    { Verify memory at offset 16 has the expected bytes }
    read_uint8(16, ctx^.ExecutionState.Memory, @val);
    assert_u32('byte 0 = $DE', TWASMUInt32(val), $DE);

    read_uint8(17, ctx^.ExecutionState.Memory, @val);
    assert_u32('byte 1 = $AD', TWASMUInt32(val), $AD);

    read_uint8(18, ctx^.ExecutionState.Memory, @val);
    assert_u32('byte 2 = $BE', TWASMUInt32(val), $BE);

    read_uint8(19, ctx^.ExecutionState.Memory, @val);
    assert_u32('byte 3 = $EF', TWASMUInt32(val), $EF);

    test_end;
end;

end.
