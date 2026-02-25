unit wasm.test.glue;
{ Tests for the wasm.pas top-level glue/trampoline unit.
  Verifies that a caller can use wasm.pas alone to load, configure,
  and execute a WASM module. }

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.context, wasm.types.stack, wasm.types.wasi,
    wasm,
    wasm.test.framework;

{ ----------------------------------------------------------------------- }
{ Minimal valid WASM binary that exports _start -> func 0                  }
{   func 0: i32.const 42, drop, end                                       }
{ This exercises: parse, find_start, tick loop                             }
{ ----------------------------------------------------------------------- }
const
    { Minimal WASM: 1 type () -> (), 1 func, 1 export "_start", 1 code body }
    TINY_MODULE_LEN = 39;

var
    TinyModule : array[0..TINY_MODULE_LEN - 1] of TWASMUInt8 = (
        { Header }
        $00, $61, $73, $6D,   { magic \0asm }
        $01, $00, $00, $00,   { version 1   }

        { Type section (id=1): 1 type () -> () }
        $01,                  { section id }
        $04,                  { section length }
        $01,                  { 1 type }
        $60,                  { func }
        $00,                  { 0 params }
        $00,                  { 0 results }

        { Function section (id=3): 1 function, type index 0 }
        $03,                  { section id }
        $02,                  { section length }
        $01,                  { 1 function }
        $00,                  { type index 0 }

        { Export section (id=7): 1 export "_start" -> func 0 }
        $07,                  { section id }
        $0A,                  { section length }
        $01,                  { 1 export }
        $06,                  { name length 6 }
        $5F, $73, $74, $61, $72, $74,  { "_start" }
        $00,                  { kind: func }
        $00,                  { index 0 }

        { Code section (id=10): 1 body }
        $0A,                  { section id }
        $07,                  { section length }
        $01,                  { 1 body }
        $05,                  { body size }
        $00,                  { 0 locals }
        $41, $2A,             { i32.const 42 }
        $1A,                  { drop }
        $0B                   { end }
    );

{ ----------------------------------------------------------------------- }
{ Mock hooks for the hook-registration tests                               }
{ ----------------------------------------------------------------------- }
var
    mock_write_called : TWASMBoolean;

function mock_fd_write(fd: TWASMUInt32; buf: TWASMPUInt8;
                       len: TWASMUInt32): TWASMUInt32;
begin
    mock_write_called := true;
    mock_fd_write := len;
end;

{ Mock host function for custom registration }
var
    mock_host_called : TWASMBoolean;

procedure mock_host_func(Context : PWASMProcessContext);
begin
    mock_host_called := true;
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 77);
end;

{ ----------------------------------------------------------------------- }
{ Tests                                                                    }
{ ----------------------------------------------------------------------- }

procedure run;
var
    ctx : PWASMProcessContext;
    bad : array[0..3] of TWASMUInt8;
begin
    test_begin('wasm (glue unit)');

    { One-time init }
    wasm.wasm_init;

    { -------------------------------------------------------------- }
    { Test 1: wasm_load parses a valid binary                        }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    assert_true('wasm_load returns non-nil', ctx <> nil);
    assert_true('wasm_load sets ValidBinary', ctx^.ValidBinary);
    assert_u32('wasm_load version=1', ctx^.Version, 1);

    { -------------------------------------------------------------- }
    { Test 2: wasm_load rejects invalid binary                       }
    { -------------------------------------------------------------- }
    bad[0] := $DE; bad[1] := $AD; bad[2] := $BE; bad[3] := $EF;
    ctx := wasm.wasm_load(@bad[0], @bad[4]);
    assert_true('wasm_load bad magic -> not valid', not ctx^.ValidBinary);

    { -------------------------------------------------------------- }
    { Test 3: wasm_start runs a tiny module to completion            }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    assert_true('module valid before start', ctx^.ValidBinary);
    assert_true('wasm_start succeeds', wasm.wasm_start(ctx));
    assert_true('not running after wasm_start', not ctx^.ExecutionState.Running);

    { -------------------------------------------------------------- }
    { Test 4: WASI hook registration via glue API                    }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    mock_write_called := false;
    wasm.wasm_set_fd_write(ctx, @mock_fd_write);
    assert_true('OnFdWrite set via glue',
                ctx^.WASIHooks.OnFdWrite <> nil);

    { -------------------------------------------------------------- }
    { Test 5: Custom host func registration via glue API             }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    mock_host_called := false;
    wasm.wasm_register_host_func(ctx, 'env', 'my_func', @mock_host_func);
    assert_u32('registry count after register', ctx^.HostFuncRegistry.Count, 1);

    { -------------------------------------------------------------- }
    { Test 6: wasm_register_wasi_preview1 registers all 46 funcs     }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    wasm.wasm_register_wasi_preview1(ctx);
    assert_u32('preview1 registers 46 funcs', ctx^.HostFuncRegistry.Count, 46);

    { -------------------------------------------------------------- }
    { Test 7: Full pipeline: load + hooks + preview1 + start         }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    wasm.wasm_set_fd_write(ctx, @mock_fd_write);
    wasm.wasm_register_wasi_preview1(ctx);
    assert_true('full pipeline start', wasm.wasm_start(ctx));
    assert_true('full pipeline finished', not ctx^.ExecutionState.Running);

    { -------------------------------------------------------------- }
    { Test 8: wasm_tick gives single-step control                    }
    { -------------------------------------------------------------- }
    ctx := wasm.wasm_load(@TinyModule[0], TWASMPUInt8(@TinyModule[0]) + TINY_MODULE_LEN);
    assert_true('wasm_prepare_start finds _start', wasm.wasm_prepare_start(ctx));
    assert_true('running after prepare', ctx^.ExecutionState.Running);
    { Tick until done }
    while wasm.wasm_tick(ctx) do ;
    assert_true('not running after tick loop', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
