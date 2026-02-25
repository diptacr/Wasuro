unit wasm.test.wasi.glue;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.heap,
    wasm.types.wasi, wasm.wasi.hooks,
    wasm.wasi.preview1.fd.write, wasm.wasi.preview1.proc.exit,
    wasm.wasi.preview1.fd.prestat, wasm.wasi.preview1.fd.fdstat,
    wasm.wasi.preview1.environ, wasm.wasi.preview1.args,
    wasm.test.framework;

var
    captured_fd  : TWASMUInt32;
    captured_buf : array[0..255] of TWASMUInt8;
    captured_len : TWASMUInt32;
    exit_code_captured : TWASMUInt32;
    exit_called : TWASMBoolean;

function mock_fd_write(fd: TWASMUInt32; buf: TWASMPUInt8;
                       len: TWASMUInt32): TWASMUInt32;
var i: TWASMUInt32;
begin
    captured_fd := fd;
    captured_len := len;
    if len > 256 then len := 256;
    for i := 0 to len - 1 do
        captured_buf[i] := buf[i];
    mock_fd_write := len;
end;

procedure mock_proc_exit(code: TWASMUInt32);
begin
    exit_called := true;
    exit_code_captured := code;
end;

procedure run;
var
    code : array[0..3] of TWASMUInt8;
    ctx  : PWASMProcessContext;
    os   : PWASMStack;
    mem  : PWasmHeap;
    errno: TWASMInt32;
    nwritten: TWASMUInt32;
begin
    test_begin('wasi.glue');

    { Initialize hooks on context }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.hooks.register_fd_write(ctx, @mock_fd_write);
    wasm.wasi.hooks.register_proc_exit(ctx, @mock_proc_exit);

    { ------------------------------------------------------------------ }
    { Test 1: fd_write with 1 iovec containing "Hi"                      }
    { ------------------------------------------------------------------ }
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    { Write "Hi" at linear memory offset 100 }
    wasm.types.heap.write_uint8(100, mem, ord('H'));
    wasm.types.heap.write_uint8(101, mem, ord('i'));

    { Write iovec at offset 200: buf_ptr=100, buf_len=2 }
    wasm.types.heap.write_uint32(200, mem, 100);  { buf_ptr }
    wasm.types.heap.write_uint32(204, mem, 2);    { buf_len }

    { Push args: fd=1, iovs_ptr=200, iovs_len=1, nwritten_ptr=300 }
    wasm.types.stack.pushi32(os, 1);     { fd = stdout }
    wasm.types.stack.pushi32(os, 200);   { iovs_ptr }
    wasm.types.stack.pushi32(os, 1);     { iovs_len }
    wasm.types.stack.pushi32(os, 300);   { nwritten_ptr }

    captured_len := 0;
    wasm.wasi.preview1.fd.write._WASI_fd_write(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32('fd_write returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    assert_u32('fd_write captured fd=1', captured_fd, 1);
    assert_u32('fd_write captured len=2', captured_len, 2);
    assert_u32('fd_write captured H', captured_buf[0], ord('H'));
    assert_u32('fd_write captured i', captured_buf[1], ord('i'));

    { Check nwritten in memory }
    wasm.types.heap.read_uint32(300, mem, @nwritten);
    assert_u32('fd_write nwritten=2', nwritten, 2);

    { ------------------------------------------------------------------ }
    { Test 2: fd_write with no hook returns ENOSYS                       }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 1);   { fd }
    wasm.types.stack.pushi32(os, 0);   { iovs_ptr }
    wasm.types.stack.pushi32(os, 0);   { iovs_len }
    wasm.types.stack.pushi32(os, 0);   { nwritten_ptr }

    wasm.wasi.preview1.fd.write._WASI_fd_write(ctx);
    errno := wasm.types.stack.popi32(os);
    assert_i32('fd_write no hook returns ENOSYS', errno, TWASMInt32(WASI_ENOSYS));

    { ------------------------------------------------------------------ }
    { Test 3: proc_exit sets ExitCode and Running=false                  }
    { ------------------------------------------------------------------ }

    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    wasm.wasi.hooks.register_proc_exit(ctx, @mock_proc_exit);
    os := ctx^.ExecutionState.Operand_Stack;

    exit_called := false;
    wasm.types.stack.pushi32(os, 42); { exit code }
    wasm.wasi.preview1.proc.exit._WASI_proc_exit(ctx);

    assert_bool('proc_exit sets Running=false', ctx^.ExecutionState.Running, false);
    assert_u32('proc_exit sets ExitCode=42', ctx^.ExitCode, 42);
    assert_true('proc_exit called OS hook', exit_called);
    assert_u32('proc_exit OS hook got code=42', exit_code_captured, 42);

    { ------------------------------------------------------------------ }
    { Test 4: fd_prestat_get returns EBADF                               }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    wasm.types.stack.pushi32(os, 3);   { fd }
    wasm.types.stack.pushi32(os, 0);   { buf_ptr }
    wasm.wasi.preview1.fd.prestat._WASI_fd_prestat_get(ctx);
    errno := wasm.types.stack.popi32(os);
    assert_i32('fd_prestat_get returns EBADF', errno, TWASMInt32(WASI_EBADF));

    { ------------------------------------------------------------------ }
    { Test 5: fd_fdstat_get for stdout returns success                   }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    wasm.types.stack.pushi32(os, TWASMInt32(WASI_FD_STDOUT)); { fd=1 }
    wasm.types.stack.pushi32(os, 400);  { buf_ptr }
    wasm.wasi.preview1.fd.fdstat._WASI_fd_fdstat_get(ctx);
    errno := wasm.types.stack.popi32(os);
    assert_i32('fd_fdstat_get stdout returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));

    { ------------------------------------------------------------------ }
    { Test 6: environ_sizes_get returns 0 count                         }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    wasm.types.stack.pushi32(os, 500);  { count_ptr }
    wasm.types.stack.pushi32(os, 504);  { buf_size_ptr }
    wasm.wasi.preview1.environ._WASI_environ_sizes_get(ctx);
    errno := wasm.types.stack.popi32(os);
    assert_i32('environ_sizes_get returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    wasm.types.heap.read_uint32(500, mem, @nwritten);
    assert_u32('environ count=0', nwritten, 0);

    { ------------------------------------------------------------------ }
    { Test 7: args_sizes_get returns 0 count                            }
    { ------------------------------------------------------------------ }
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;
    mem := ctx^.ExecutionState.Memory;

    wasm.types.stack.pushi32(os, 600);  { count_ptr }
    wasm.types.stack.pushi32(os, 604);  { buf_size_ptr }
    wasm.wasi.preview1.args._WASI_args_sizes_get(ctx);
    errno := wasm.types.stack.popi32(os);
    assert_i32('args_sizes_get returns ESUCCESS', errno, TWASMInt32(WASI_ESUCCESS));
    wasm.types.heap.read_uint32(600, mem, @nwritten);
    assert_u32('args count=0', nwritten, 0);

    test_end;
end;

end.
