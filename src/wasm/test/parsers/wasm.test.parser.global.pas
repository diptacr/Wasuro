unit wasm.test.parser.global;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.context, wasm.test.framework,
    wasm.parser.sections.globalSection;

procedure run;
var
    buf : array[0..5] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('parser.global');

    { Build binary: 1 mutable i32 global initialized to 42
      Buffer: [$01, $7F, $01, $41, $2A, $0B]
      $01 = 1 global
      $7F = i32, $01 = mutable
      $41 = i32.const, $2A = 42, $0B = end }
    buf[0] := $01; { global_count = 1 }
    buf[1] := $7F; { valtype = i32 }
    buf[2] := $01; { mutable = true }
    buf[3] := $41; { i32.const opcode }
    buf[4] := $2A; { 42 }
    buf[5] := $0B; { end }

    ctx := make_test_context(nil, 0);
    wasm.parser.sections.globalSection.handle(@buf[0], 6, ctx);

    assert_u32('GlobalCount=1', ctx^.ExecutionState.Globals^.GlobalCount, 1);
    assert_u32('Globals[0].ValueType=vti32', TWASMUInt32(ctx^.ExecutionState.Globals^.Globals[0].ValueType), TWASMUInt32(vti32));
    assert_bool('Globals[0].Mutable=true', ctx^.ExecutionState.Globals^.Globals[0].Mutable, true);
    assert_i32('Globals[0].Value.i32Value=42', ctx^.ExecutionState.Globals^.Globals[0].Value.i32Value, 42);

    test_end;
end;

end.
