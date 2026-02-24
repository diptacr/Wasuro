{ E2E test: use local variables, local.set 0 := 10, local.set 1 := 20,
  return local.get 0 + local.get 1 = 30
  Equivalent WAT:
    (module
      (func (export "main") (result i32) (local i32 i32)
        i32.const 10
        local.set 0
        i32.const 20
        local.set 1
        local.get 0
        local.get 1
        i32.add
        return
      )
    )
}
unit wasm.test.binary.locals;

interface

procedure run;

implementation

uses
    types, console, wasm.types, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

const
  BINARY_SIZE = 51;
  BINARY : Array[$00..$32] of uint8 = (
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }
    $01, $05, $01, $60,       { type section: 1 func type }
    $00, $01, $7F,            { () -> (i32) }
    $03, $02, $01, $00,       { function section: 1 func, type 0 }
    $07, $08, $01, $04,       { export section: 1 export, name len 4 }
    $6D, $61, $69, $6E,       { "main" }
    $00, $00,                 { export type=func, index=0 }
    $0A, $14, $01, $12,       { code section: len=20, count=1, body=18 }
    $01, $02, $7F,            { 1 local type entry: 2 x i32 }
    $41, $0A,                 { i32.const 10 }
    $21, $00,                 { local.set 0 }
    $41, $14,                 { i32.const 20 }
    $21, $01,                 { local.set 1 }
    $20, $00,                 { local.get 0 }
    $20, $01,                 { local.get 1 }
    $6A,                      { i32.add }
    $0F, $0B                  { return, end }
  );

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.locals');

    ctx := wasm.parser.parse(@BINARY[0], puint8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);

    { Set up locals from the parsed code entry for the single function }
    ctx^.ExecutionState.Locals := @ctx^.Sections.CodeSection^.Entries[0].Locals;

    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('10+20=30', popi32(ctx^.ExecutionState.Operand_Stack), 30);

    test_end;
end;

end.
