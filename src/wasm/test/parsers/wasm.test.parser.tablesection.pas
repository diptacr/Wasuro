unit wasm.test.parser.tablesection;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.parser.sections.tableSection,
    wasm.test.framework;

procedure run;
var
    buf: array[0..15] of TWASMUInt8;
    ctx: PWASMProcessContext;
begin
    test_begin('parser.tablesection');

    { Test 1: single funcref table with min=2, no max }
    buf[0] := $01;  { table count = 1 }
    buf[1] := $70;  { element type = funcref }
    buf[2] := $00;  { limits flag = min only }
    buf[3] := $02;  { min = 2 }
    ctx := make_test_context(@buf[0], 4);
    wasm.parser.sections.tableSection.handle(@buf[0], 4, ctx);
    assert_u32('table count=1',
               ctx^.ExecutionState.Tables^.TableCount, 1);
    assert_u32('table min=2',
               ctx^.ExecutionState.Tables^.Tables[0].Size, 2);
    assert_bool('table hasMax=false',
                ctx^.ExecutionState.Tables^.Tables[0].HasMax, false);

    { Test 2: funcref table with min=4, max=10 }
    buf[0] := $01;  { table count = 1 }
    buf[1] := $70;  { funcref }
    buf[2] := $01;  { limits flag = min + max }
    buf[3] := $04;  { min = 4 }
    buf[4] := $0A;  { max = 10 }
    ctx := make_test_context(@buf[0], 5);
    wasm.parser.sections.tableSection.handle(@buf[0], 5, ctx);
    assert_u32('table min=4',
               ctx^.ExecutionState.Tables^.Tables[0].Size, 4);
    assert_u32('table max=10',
               ctx^.ExecutionState.Tables^.Tables[0].MaxSize, 10);
    assert_bool('table hasMax=true',
                ctx^.ExecutionState.Tables^.Tables[0].HasMax, true);

    { Test 3: elements initialized to $FFFFFFFF (uninitialized sentinel) }
    assert_u32('element[0] uninitialized',
               ctx^.ExecutionState.Tables^.Tables[0].Elements[0], $FFFFFFFF);
    assert_u32('element[3] uninitialized',
               ctx^.ExecutionState.Tables^.Tables[0].Elements[3], $FFFFFFFF);

    test_end;
end;

end.
