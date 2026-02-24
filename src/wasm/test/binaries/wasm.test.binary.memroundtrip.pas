{ E2E test: store 99 to linear memory, load it back = 99
  Equivalent WAT:
    (module
      (memory 1)
      (func (export "main") (result i32)
        i32.const 0
        i32.const 99
        i32.store offset=0 align=0
        i32.const 0
        i32.load offset=0 align=0
        return
      )
    )
}
unit wasm.test.binary.memroundtrip;

interface

procedure run;

implementation

uses
    wasm.types.builtin, console, wasm.types.context, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

const
  BINARY_SIZE = 53;
  BINARY : Array[$00..$34] of TWASMUInt8 = (
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }
    $01, $05, $01, $60,       { type section: 1 func type }
    $00, $01, $7F,            { () -> (i32) }
    $03, $02, $01, $00,       { function section: 1 func, type 0 }
    $05, $03, $01, $00, $01,  { memory section: 1 memory, no max, 1 page }
    $07, $08, $01, $04,       { export section: 1 export, name len 4 }
    $6D, $61, $69, $6E,       { "main" }
    $00, $00,                 { export type=func, index=0 }
    $0A, $11, $01, $0F,       { code section: len=17, count=1, body=15 }
    $00,                      { 0 locals }
    $41, $00,                 { i32.const 0  (address) }
    $41, $63,                 { i32.const 99 (value) }
    $36, $00, $00,            { i32.store align=0 offset=0 }
    $41, $00,                 { i32.const 0  (address) }
    $28, $00, $00,            { i32.load align=0 offset=0 }
    $0F, $0B                  { return, end }
  );

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.memroundtrip');

    ctx := wasm.parser.parse(@BINARY[0], TWASMPUInt8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);

    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('store+load=99', popi32(ctx^.ExecutionState.Operand_Stack), 99);

    test_end;
end;

end.
