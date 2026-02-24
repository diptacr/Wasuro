unit wasm.test.parser.importsection;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.context, wasm.test.framework,
    wasm.parser.sections.importSection;

procedure run;
var
    buf : array[0..31] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.import');

    { Test 1: Single function import "env"."puts" with type index 0
      Binary layout:
        01           import_count = 1
        03           module_name_length = 3
        65 6E 76     "env"
        04           field_name_length = 4
        70 75 74 73  "puts"
        00           desc_kind = function
        00           type_index = 0
    }
    buf[0]  := $01; { import_count = 1 }
    buf[1]  := $03; { module_name_length = 3 }
    buf[2]  := $65; { 'e' }
    buf[3]  := $6E; { 'n' }
    buf[4]  := $76; { 'v' }
    buf[5]  := $04; { field_name_length = 4 }
    buf[6]  := $70; { 'p' }
    buf[7]  := $75; { 'u' }
    buf[8]  := $74; { 't' }
    buf[9]  := $73; { 's' }
    buf[10] := $00; { desc_kind = function }
    buf[11] := $00; { type_index = 0 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.importSection.handle(@buf[0], 12, ctx);

    assert_u32('ImportCount=1', ctx^.Sections.ImportSection^.ImportCount, 1);
    assert_u32('ModuleNameLen=3', ctx^.Sections.ImportSection^.Entries[0].ModuleNameLength, 3);
    assert_u32('FieldNameLen=4', ctx^.Sections.ImportSection^.Entries[0].FieldNameLength, 4);
    assert_true('Kind=func', ctx^.Sections.ImportSection^.Entries[0].Desc.Kind = $00);
    assert_u32('TypeIndex=0', ctx^.Sections.ImportSection^.Entries[0].Desc.TypeIndex, 0);

    { Test 2: Memory import "js"."mem" with min=1, max=2
      Binary layout:
        01           import_count = 1
        02           module_name_length = 2
        6A 73        "js"
        03           field_name_length = 3
        6D 65 6D     "mem"
        02           desc_kind = memory
        01           limits_flag = has_max
        01           limits_min = 1
        02           limits_max = 2
    }
    buf[0]  := $01; { import_count = 1 }
    buf[1]  := $02; { module_name_length = 2 }
    buf[2]  := $6A; { 'j' }
    buf[3]  := $73; { 's' }
    buf[4]  := $03; { field_name_length = 3 }
    buf[5]  := $6D; { 'm' }
    buf[6]  := $65; { 'e' }
    buf[7]  := $6D; { 'm' }
    buf[8]  := $02; { desc_kind = memory }
    buf[9]  := $01; { limits_flag = 1 (has max) }
    buf[10] := $01; { limits_min = 1 }
    buf[11] := $02; { limits_max = 2 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.importSection.handle(@buf[0], 12, ctx);

    assert_u32('ImportCount=1', ctx^.Sections.ImportSection^.ImportCount, 1);
    assert_true('Kind=memory', ctx^.Sections.ImportSection^.Entries[0].Desc.Kind = $02);
    assert_true('HasMax=true', ctx^.Sections.ImportSection^.Entries[0].Desc.HasMax = true);
    assert_u32('LimitsMin=1', ctx^.Sections.ImportSection^.Entries[0].Desc.LimitsMin, 1);
    assert_u32('LimitsMax=2', ctx^.Sections.ImportSection^.Entries[0].Desc.LimitsMax, 2);

    { Test 3: Global import "env"."g" immutable i32
      Binary layout:
        01           import_count = 1
        03           module_name_length = 3
        65 6E 76     "env"
        01           field_name_length = 1
        67           "g"
        03           desc_kind = global
        7F           global_valtype = i32
        00           global_mut = immutable
    }
    buf[0]  := $01; { import_count = 1 }
    buf[1]  := $03; { module_name_length = 3 }
    buf[2]  := $65; { 'e' }
    buf[3]  := $6E; { 'n' }
    buf[4]  := $76; { 'v' }
    buf[5]  := $01; { field_name_length = 1 }
    buf[6]  := $67; { 'g' }
    buf[7]  := $03; { desc_kind = global }
    buf[8]  := $7F; { global_valtype = i32 }
    buf[9]  := $00; { global_mut = 0 (immutable) }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.importSection.handle(@buf[0], 10, ctx);

    assert_u32('ImportCount=1', ctx^.Sections.ImportSection^.ImportCount, 1);
    assert_true('Kind=global', ctx^.Sections.ImportSection^.Entries[0].Desc.Kind = $03);
    assert_true('ValType=i32', ctx^.Sections.ImportSection^.Entries[0].Desc.GlobalValType = $7F);
    assert_true('Mut=false', ctx^.Sections.ImportSection^.Entries[0].Desc.GlobalMut = false);

    test_end;
end;

end.
