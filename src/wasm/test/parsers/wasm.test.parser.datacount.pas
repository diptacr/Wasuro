unit wasm.test.parser.datacount;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context,
    wasm.test.framework, wasm.parser.sections.dataCountSection;

procedure run;
var
    buf : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.datacount');

    { DataCount section with count = 3 (single LEB128 byte) }
    buf[0] := $03;
    ctx := make_test_context(nil, 0);
    wasm.parser.sections.dataCountSection.handle(@buf[0], 1, ctx);
    assert_u32('data_count=3', ctx^.ExecutionState.DataSegments^.SegmentCount, 3);

    { DataCount section with count = 0 }
    buf[0] := $00;
    ctx := make_test_context(nil, 0);
    wasm.parser.sections.dataCountSection.handle(@buf[0], 1, ctx);
    assert_u32('data_count=0', ctx^.ExecutionState.DataSegments^.SegmentCount, 0);

    test_end;
end;

end.
