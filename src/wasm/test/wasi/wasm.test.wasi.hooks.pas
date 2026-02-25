unit wasm.test.wasi.hooks;

interface

procedure run;

implementation

uses
    wasm.types.builtin,
    wasm.types.context,
    wasm.types.wasi,
    wasm.wasi.hooks,
    wasm.test.framework;

var
    write_called : TWASMBoolean;
    write_fd     : TWASMUInt32;
    write_len    : TWASMUInt32;
    exit_called  : TWASMBoolean;
    exit_code    : TWASMUInt32;

function mock_write(fd: TWASMUInt32; buf: TWASMPUInt8;
                    len: TWASMUInt32): TWASMUInt32;
begin
    write_called := true;
    write_fd := fd;
    write_len := len;
    mock_write := len;
end;

function mock_write_alt(fd: TWASMUInt32; buf: TWASMPUInt8;
                        len: TWASMUInt32): TWASMUInt32;
begin
    mock_write_alt := 0; { always returns 0 }
end;

procedure mock_proc_exit(code: TWASMUInt32);
begin
    exit_called := true;
    exit_code := code;
end;

procedure run;
var
    ctx   : PWASMProcessContext;
    ctx2  : PWASMProcessContext;
    hooks : PWASIHookTable;
    buf   : array[0..3] of TWASMUInt8;
    code  : array[0..0] of TWASMUInt8;
begin
    test_begin('wasi.hooks');

    code[0] := $0B;

    { ------------------------------------------------------------------ }
    { Test 1: Init hook table — all hooks should be nil                  }
    { ------------------------------------------------------------------ }
    ctx := make_test_context(@code[0], 1);
    hooks := @ctx^.WASIHooks;
    assert_true('hook table exists', hooks <> nil);
    assert_true('OnFdWrite initially nil', hooks^.OnFdWrite = nil);
    assert_true('OnFdRead initially nil', hooks^.OnFdRead = nil);
    assert_true('OnProcExit initially nil', hooks^.OnProcExit = nil);

    { ------------------------------------------------------------------ }
    { Test 2: Register fd_write hook on context                          }
    { ------------------------------------------------------------------ }
    wasm.wasi.hooks.register_fd_write(ctx, @mock_write);
    assert_true('OnFdWrite registered', hooks^.OnFdWrite <> nil);

    { ------------------------------------------------------------------ }
    { Test 3: Call registered fd_write hook                              }
    { ------------------------------------------------------------------ }
    write_called := false;
    buf[0] := 72; buf[1] := 101; buf[2] := 108; buf[3] := 108; { Hell }
    hooks^.OnFdWrite(WASI_FD_STDOUT, @buf[0], 4);
    assert_true('fd_write hook called', write_called);
    assert_u32('fd_write got fd=1', write_fd, WASI_FD_STDOUT);
    assert_u32('fd_write got len=4', write_len, 4);

    { ------------------------------------------------------------------ }
    { Test 4: Register proc_exit hook on context                         }
    { ------------------------------------------------------------------ }
    wasm.wasi.hooks.register_proc_exit(ctx, @mock_proc_exit);
    assert_true('OnProcExit registered', hooks^.OnProcExit <> nil);

    exit_called := false;
    hooks^.OnProcExit(42);
    assert_true('proc_exit hook called', exit_called);
    assert_u32('proc_exit got code=42', exit_code, 42);

    { ------------------------------------------------------------------ }
    { Test 5: Two contexts have independent WASI hooks                   }
    { ------------------------------------------------------------------ }
    ctx := make_test_context(@code[0], 1);
    ctx2 := make_test_context(@code[0], 1);

    wasm.wasi.hooks.register_fd_write(ctx, @mock_write);
    wasm.wasi.hooks.register_fd_write(ctx2, @mock_write_alt);

    assert_true('ctx has mock_write', ctx^.WASIHooks.OnFdWrite = @mock_write);
    assert_true('ctx2 has mock_write_alt', ctx2^.WASIHooks.OnFdWrite = @mock_write_alt);
    assert_true('ctx.OnProcExit still nil', ctx^.WASIHooks.OnProcExit = nil);

    { ------------------------------------------------------------------ }
    { Test 6: init_hook_table clears all hooks on context                }
    { ------------------------------------------------------------------ }
    wasm.wasi.hooks.register_proc_exit(ctx, @mock_proc_exit);
    assert_true('OnProcExit set before init', ctx^.WASIHooks.OnProcExit <> nil);
    wasm.wasi.hooks.init_hook_table(ctx);
    assert_true('OnProcExit nil after init', ctx^.WASIHooks.OnProcExit = nil);
    assert_true('OnFdWrite nil after init', ctx^.WASIHooks.OnFdWrite = nil);

    test_end;
end;

end.
