{ E2E test: () -> i32, returns 42
  Equivalent WAT:
    (module
      (func (export "main") (result i32)
        i32.const 42
        return
      )
    )
}
unit wasm.test.binary.return42;

interface

uses
    wasm.types.builtin;

const
  BINARY_SIZE = $26;
  BINARY : Array[$0..$25] of TWASMUInt8 = (
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }
    $01, $05, $01, $60,       { type section: 1 func type }
    $00, $01, $7F,            { () -> (i32) }
    $03, $02, $01, $00,       { function section: 1 func, type 0 }
    $07, $08, $01, $04,       { export section: 1 export, name len 4 }
    $6D, $61, $69, $6E,       { "main" }
    $00, $00,                 { export type=func, index=0 }
    $0A, $07, $01,            { code section: len=7, count=1 }
    $05, $00,                 { body_size=5, 0 locals }
    $41, $2A, $0F, $0B        { i32.const 42, return, end }
  );

procedure run;

implementation

uses
    console, wasm.types, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.return42');

    ctx := wasm.parser.parse(@BINARY[0], TWASMPUInt8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);
    assert_u32('version=1', ctx^.Version, 1);

    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('result=42', popi32(ctx^.ExecutionState.Operand_Stack), 42);

    test_end;
end;

end.
