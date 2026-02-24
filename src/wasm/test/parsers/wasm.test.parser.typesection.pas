unit wasm.test.parser.typesection;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types, wasm.test.framework,
    wasm.parser.sections.typeSection;

procedure run;
var
    buf : array[0..9] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.type');

    { Build binary: 2 wasm.types.builtin
      Type 0: (i32, i32) -> (i32)
      Type 1: () -> ()
      Buffer: [$02, $60, $02, $7F, $7F, $01, $7F, $60, $00, $00] }
    buf[0] := $02; { type_count = 2 }
    buf[1] := $60; { func type marker }
    buf[2] := $02; { param_count = 2 }
    buf[3] := $7F; { i32 }
    buf[4] := $7F; { i32 }
    buf[5] := $01; { return_count = 1 }
    buf[6] := $7F; { i32 }
    buf[7] := $60; { func type marker }
    buf[8] := $00; { param_count = 0 }
    buf[9] := $00; { return_count = 0 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.typeSection.handle(@buf[0], 10, ctx);

    assert_u32('TypeCount=2', ctx^.Sections.TypeSection^.TypeCount, 2);

    { Type 0 }
    assert_u32('Type[0]._type=$60', TWASMUInt32(ctx^.Sections.TypeSection^.Types[0]._type), $60);
    assert_u32('Type[0].ParamCount=2', ctx^.Sections.TypeSection^.Types[0].ParamCount, 2);
    assert_u32('Type[0].Param[0]=vti32', TWASMUInt32(ctx^.Sections.TypeSection^.Types[0].ParamTypes[0].ValueType), TWASMUInt32(vti32));
    assert_u32('Type[0].Param[1]=vti32', TWASMUInt32(ctx^.Sections.TypeSection^.Types[0].ParamTypes[1].ValueType), TWASMUInt32(vti32));
    assert_u32('Type[0].ReturnCount=1', ctx^.Sections.TypeSection^.Types[0].ReturnCount, 1);
    assert_u32('Type[0].Return[0]=vti32', TWASMUInt32(ctx^.Sections.TypeSection^.Types[0].ReturnTypes[0].ValueType), TWASMUInt32(vti32));

    { Type 1 }
    assert_u32('Type[1]._type=$60', TWASMUInt32(ctx^.Sections.TypeSection^.Types[1]._type), $60);
    assert_u32('Type[1].ParamCount=0', ctx^.Sections.TypeSection^.Types[1].ParamCount, 0);
    assert_u32('Type[1].ReturnCount=0', ctx^.Sections.TypeSection^.Types[1].ReturnCount, 0);

    test_end;
end;

end.
