unit wasm.test.parser.code;

interface

procedure run;

implementation

uses
    types, lmemorymanager,
    wasm.types, wasm.test.framework,
    wasm.parser.sections.codeSection;

procedure run;
var
    buf : array[0..4] of uint8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.code');

    { Build binary: 1 code entry with 0 locals and 2 bytes of code [nop, end]
      body_size = 3 (1 byte for local_type_count=0, 2 bytes code)
      Buffer: [$01, $03, $00, $01, $0B] }
    buf[0] := $01; { code_count = 1 }
    buf[1] := $03; { body_size = 3 }
    buf[2] := $00; { local_type_count = 0 }
    buf[3] := $01; { nop }
    buf[4] := $0B; { end }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.codeSection.handle(@buf[0], 5, ctx);

    assert_u32('CodeCount=1', ctx^.Sections.CodeSection^.CodeCount, 1);
    assert_u32('Entries[0].SectionLength=3', ctx^.Sections.CodeSection^.Entries[0].SectionLength, 3);
    assert_u32('Entries[0].CodeLength=2', ctx^.Sections.CodeSection^.Entries[0].CodeLength, 2);
    assert_u32('Entries[0].Locals.TypeCount=0', ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount, 0);
    assert_u32('Entries[0].Locals.LocalCount=0', ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount, 0);

    { Verify code bytes }
    assert_u32('code[0]=nop', uint32(ctx^.Sections.CodeSection^.Entries[0].Code[0]), $01);
    assert_u32('code[1]=end', uint32(ctx^.Sections.CodeSection^.Entries[0].Code[1]), $0B);

    test_end;
end;

end.
