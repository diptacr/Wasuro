unit wasm.test.parser.start;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types, wasm.test.framework,
    wasm.parser.sections.startSection;

procedure run;
var
    buf : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.start');

    { Build binary: start function index = 5
      Buffer: [$05] }
    buf[0] := $05; { function_index = 5 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.startSection.handle(@buf[0], 1, ctx);

    assert_i32('StartIndex=5', ctx^.Sections.StartIndex, 5);

    test_end;
end;

end.
