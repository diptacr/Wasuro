{ E2E test: (2 + 3) * 4 = 20
  Equivalent WAT:
    (module
      (func (export "main") (result i32)
        i32.const 2
        i32.const 3
        i32.add
        i32.const 4
        i32.mul
        return
      )
    )
}
unit wasm.test.binary.arithmetic;

interface

procedure run;

implementation

uses
    wasm.types.builtin, console, wasm.types.context, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

const
  BINARY_SIZE = 44;
  BINARY : Array[$00..$2B] of TWASMUInt8 = (
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }
    $01, $05, $01, $60,       { type section: 1 func type }
    $00, $01, $7F,            { () -> (i32) }
    $03, $02, $01, $00,       { function section: 1 func, type 0 }
    $07, $08, $01, $04,       { export section: 1 export, name len 4 }
    $6D, $61, $69, $6E,       { "main" }
    $00, $00,                 { export type=func, index=0 }
    $0A, $0D, $01, $0B,       { code section: len=13, count=1, body=11 }
    $00,                      { 0 locals }
    $41, $02,                 { i32.const 2 }
    $41, $03,                 { i32.const 3 }
    $6A,                      { i32.add }
    $41, $04,                 { i32.const 4 }
    $6C,                      { i32.mul }
    $0F, $0B                  { return, end }
  );

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.arithmetic');

    ctx := wasm.parser.parse(@BINARY[0], TWASMPUInt8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);

    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('(2+3)*4=20', popi32(ctx^.ExecutionState.Operand_Stack), 20);

    test_end;
end;

end.
