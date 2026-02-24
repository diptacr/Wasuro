unit wasm.test.parser.memory;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.context, wasm.test.framework,
    wasm.parser.sections.memorySection;

procedure run;
var
    buf : array[0..3] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.memory');

    { Build binary: 1 memory with initial=1 page, max=4 pages
      Buffer: [$01, $01, $01, $04]
      $01 = 1 memory
      $01 = flags (has max)
      $01 = initial pages = 1
      $04 = max pages = 4 }
    buf[0] := $01; { memory_count = 1 }
    buf[1] := $01; { flags = 1 (has max) }
    buf[2] := $01; { initial_pages = 1 }
    buf[3] := $04; { max_pages = 4 }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.memorySection.handle(@buf[0], 4, ctx);

    assert_u32('MemoryCount=1', ctx^.Sections.MemorySection^.MemoryCount, 1);
    assert_bool('Memories[0].HasMax=true', ctx^.Sections.MemorySection^.Memories[0].HasMax, true);
    assert_u32('Memories[0].InitialPages=1', ctx^.Sections.MemorySection^.Memories[0].InitialPages, 1);
    assert_u32('Memories[0].MaxPages=4', ctx^.Sections.MemorySection^.Memories[0].MaxPages, 4);

    test_end;
end;

end.
