unit wasm.test.parser.elementsection;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.parser.sections.elementSection,
    wasm.test.framework;

procedure run;
var
    buf: array[0..31] of TWASMUInt8;
    ctx: PWASMProcessContext;
    i: TWASMUInt32;
begin
    test_begin('parser.elementsection');

    { Test 1: mode 0 active segment — 3 function indices at offset 1 in table 0
      Segment format (mode 0):
        $00          - mode 0 (active, table 0, i32 offset expr)
        $41 $01 $0B  - init expr: i32.const 1, end
        $03          - 3 function indices
        $05 $0A $0F  - func indices: 5, 10, 15
    }
    buf[0] := $01;  { segment count = 1 }
    buf[1] := $00;  { mode 0 }
    buf[2] := $41;  { i32.const }
    buf[3] := $01;  { offset = 1 }
    buf[4] := $0B;  { end }
    buf[5] := $03;  { 3 func indices }
    buf[6] := $05;  { func 5 }
    buf[7] := $0A;  { func 10 }
    buf[8] := $0F;  { func 15 }

    ctx := make_test_context(@buf[0], 9);
    { Set up a table with 8 elements (all uninitialized) }
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].ElementType := $70;
    ctx^.ExecutionState.Tables^.Tables[0].Size := 8;
    ctx^.ExecutionState.Tables^.Tables[0].MaxSize := 8;
    ctx^.ExecutionState.Tables^.Tables[0].HasMax := true;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(sizeof(TWASMUInt32) * 8));
    for i := 0 to 7 do
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := $FFFFFFFF;

    wasm.parser.sections.elementSection.handle(@buf[0], 9, ctx);

    { Element[0] should still be uninitialized }
    assert_u32('elem[0] untouched', ctx^.ExecutionState.Tables^.Tables[0].Elements[0], $FFFFFFFF);
    { Elements at offset 1..3 should be filled }
    assert_u32('elem[1]=5', ctx^.ExecutionState.Tables^.Tables[0].Elements[1], 5);
    assert_u32('elem[2]=10', ctx^.ExecutionState.Tables^.Tables[0].Elements[2], 10);
    assert_u32('elem[3]=15', ctx^.ExecutionState.Tables^.Tables[0].Elements[3], 15);
    { Element[4] should still be uninitialized }
    assert_u32('elem[4] untouched', ctx^.ExecutionState.Tables^.Tables[0].Elements[4], $FFFFFFFF);

    test_end;
end;

end.
