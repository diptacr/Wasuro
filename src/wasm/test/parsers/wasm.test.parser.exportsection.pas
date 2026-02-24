unit wasm.test.parser.exportsection;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.context, wasm.test.framework,
    wasm.parser.sections.exportSection;

procedure run;
var
    buf : array[0..7] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.export');

    { Build binary: 1 export named "main" as function index 0
      "main" = $6D $61 $69 $6E
      Buffer: [$01, $04, $6D, $61, $69, $6E, $00, $00] }
    buf[0] := $01; { export_count = 1 }
    buf[1] := $04; { name_length = 4 }
    buf[2] := $6D; { 'm' }
    buf[3] := $61; { 'a' }
    buf[4] := $69; { 'i' }
    buf[5] := $6E; { 'n' }
    buf[6] := $00; { export_type = function }
    buf[7] := $00; { function_index = 0 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.exportSection.handle(@buf[0], 8, ctx);

    assert_u32('ExportCount=1', ctx^.Sections.ExportSection^.ExportCount, 1);
    assert_u32('Entries[0].NameLength=4', ctx^.Sections.ExportSection^.Entries[0].NameLength, 4);
    assert_true('Entries[0].ExportType=etFunc', ctx^.Sections.ExportSection^.Entries[0].ExportType = etFunc);
    assert_u32('Entries[0].FunctionIndex=0', ctx^.Sections.ExportSection^.Entries[0].FunctionIndex, 0);

    test_end;
end;

end.
