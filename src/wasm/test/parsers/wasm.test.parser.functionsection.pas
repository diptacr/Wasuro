unit wasm.test.parser.functionsection;

interface

procedure run;

implementation

uses
    types, lmemorymanager,
    wasm.types, wasm.test.framework,
    wasm.parser.sections.functionSection;

procedure run;
var
    buf : array[0..3] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.function');

    { Build binary: 3 functions referencing types 0, 1, 0
      Buffer: [$03, $00, $01, $00] }
    buf[0] := $03; { function_count = 3 }
    buf[1] := $00; { type_index = 0 }
    buf[2] := $01; { type_index = 1 }
    buf[3] := $00; { type_index = 0 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.functionSection.handle(@buf[0], 4, ctx);

    assert_u32('FunctionCount=3', ctx^.Sections.FunctionSection^.FunctionCount, 3);
    assert_u32('Functions[0].Index=0', ctx^.Sections.FunctionSection^.Functions[0].Index, 0);
    assert_u32('Functions[1].Index=1', ctx^.Sections.FunctionSection^.Functions[1].Index, 1);
    assert_u32('Functions[2].Index=0', ctx^.Sections.FunctionSection^.Functions[2].Index, 0);

    test_end;
end;

end.
