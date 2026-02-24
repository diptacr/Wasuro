{ E2E test: i32.const 10 + i32.const 32 = 42
  Equivalent WAT:
    (module
      (func (export "main") (result i32)
        i32.const 10
        i32.const 32
        i32.add
        return
      )
    )
}
unit wasm.test.binary.addnums;

interface

procedure run;

implementation

uses
    types, console, wasm.types, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

const
  BINARY_SIZE = 41;
  BINARY : Array[$00..$28] of uint8 = (
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }
    $01, $05, $01, $60,       { type section: 1 func type }
    $00, $01, $7F,            { () -> (i32) }
    $03, $02, $01, $00,       { function section: 1 func, type 0 }
    $07, $08, $01, $04,       { export section: 1 export, name len 4 }
    $6D, $61, $69, $6E,       { "main" }
    $00, $00,                 { export type=func, index=0 }
    $0A, $0A, $01, $08,       { code section: len=10, count=1, body=8 }
    $00,                      { 0 locals }
    $41, $0A,                 { i32.const 10 }
    $41, $20,                 { i32.const 32 }
    $6A,                      { i32.add }
    $0F, $0B                  { return, end }
  );

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.addnums');

    ctx := wasm.parser.parse(@BINARY[0], puint8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);

    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('10+32=42', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    test_end;
end;

end.
