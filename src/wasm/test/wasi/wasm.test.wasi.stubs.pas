unit wasm.test.wasi.stubs;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.stack, wasm.types.heap,
    wasm.types.wasi,
    wasm.wasi.preview1.fd.stubs, wasm.wasi.preview1.path, wasm.wasi.preview1.poll, wasm.wasi.preview1.sock,
    wasm.test.framework;

{ Helper: create a fresh context, push dummy args, call stub, assert ENOSYS }
procedure assert_stub_enosys(name : TWASMPChar; stub : TWASMHostFunc;
    ni32 : TWASMUInt32; ni64 : TWASMUInt32);
var
    code : array[0..0] of TWASMUInt8;
    ctx  : PWASMProcessContext;
    os   : PWASMStack;
    i    : TWASMUInt32;
    errno: TWASMInt32;
begin
    code[0] := $0B;
    ctx := make_test_context(@code[0], 1);
    os := ctx^.ExecutionState.Operand_Stack;

    { Push i32 args first (they'll be at the bottom) }
    for i := 1 to ni32 do
        wasm.types.stack.pushi32(os, TWASMInt32(i));

    { Then i64 args (on top, since we pop in reverse) }
    for i := 1 to ni64 do
        wasm.types.stack.pushi64(os, TWASMInt64(i));

    stub(ctx);

    errno := wasm.types.stack.popi32(os);
    assert_i32(name, errno, TWASMInt32(WASI_ENOSYS));
    assert_u32(name, os^.Top, 0); { stack must be clean }
end;

procedure run;
begin
    test_begin('wasi.stubs');

    { ================================================================== }
    { Tier 3 — fd_* stubs                                                }
    { ================================================================== }

    { fd_readdir(fd, buf, buf_len, cookie:i64, bufused) → errno }
    assert_stub_enosys('fd_readdir returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_readdir, 3, 1);

    { fd_filestat_get(fd, buf) → errno }
    assert_stub_enosys('fd_filestat_get returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_get, 2, 0);

    { fd_filestat_set_size(fd, size:i64) → errno }
    assert_stub_enosys('fd_filestat_set_size returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_set_size, 1, 1);

    { fd_filestat_set_times(fd, atim:i64, mtim:i64, fst_flags) → errno }
    assert_stub_enosys('fd_filestat_set_times returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_set_times, 2, 2);

    { fd_pread(fd, iovs, iovs_len, offset:i64, nread) → errno }
    assert_stub_enosys('fd_pread returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_pread, 3, 1);

    { fd_pwrite(fd, iovs, iovs_len, offset:i64, nwritten) → errno }
    assert_stub_enosys('fd_pwrite returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_pwrite, 3, 1);

    { fd_sync(fd) → errno }
    assert_stub_enosys('fd_sync returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_sync, 1, 0);

    { fd_datasync(fd) → errno }
    assert_stub_enosys('fd_datasync returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_datasync, 1, 0);

    { fd_tell(fd, offset) → errno }
    assert_stub_enosys('fd_tell returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_tell, 2, 0);

    { fd_advise(fd, offset:i64, len:i64, advice) → errno }
    assert_stub_enosys('fd_advise returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_advise, 2, 2);

    { fd_allocate(fd, offset:i64, len:i64) → errno }
    assert_stub_enosys('fd_allocate returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_allocate, 1, 2);

    { fd_renumber(fd, to) → errno }
    assert_stub_enosys('fd_renumber returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_renumber, 2, 0);

    { fd_fdstat_set_flags(fd, flags) → errno }
    assert_stub_enosys('fd_fdstat_set_flags returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_fdstat_set_flags, 2, 0);

    { fd_fdstat_set_rights(fd, base:i64, inheriting:i64) → errno }
    assert_stub_enosys('fd_fdstat_set_rights returns ENOSYS',
        @wasm.wasi.preview1.fd.stubs._WASI_fd_fdstat_set_rights, 1, 2);

    { ================================================================== }
    { Tier 3 — path_* stubs                                              }
    { ================================================================== }

    { path_open(fd, dirflags, path, path_len, oflags, base:i64, inh:i64, fdflags, opened_fd) → errno }
    assert_stub_enosys('path_open returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_open, 5, 2);

    { path_filestat_get(fd, flags, path, path_len, buf) → errno }
    assert_stub_enosys('path_filestat_get returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_filestat_get, 5, 0);

    { path_create_directory(fd, path, path_len) → errno }
    assert_stub_enosys('path_create_directory returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_create_directory, 3, 0);

    { path_remove_directory(fd, path, path_len) → errno }
    assert_stub_enosys('path_remove_directory returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_remove_directory, 3, 0);

    { path_unlink_file(fd, path, path_len) → errno }
    assert_stub_enosys('path_unlink_file returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_unlink_file, 3, 0);

    { path_rename(fd, old_path, old_len, new_fd, new_path, new_len) → errno }
    assert_stub_enosys('path_rename returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_rename, 6, 0);

    { path_readlink(fd, path, path_len, buf, buf_len, bufused) → errno }
    assert_stub_enosys('path_readlink returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_readlink, 6, 0);

    { path_symlink(old_path, old_path_len, fd, new_path, new_path_len) → errno }
    assert_stub_enosys('path_symlink returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_symlink, 5, 0);

    { path_link(old_fd, old_flags, old_path, old_path_len, new_fd, new_path, new_path_len) → errno }
    assert_stub_enosys('path_link returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_link, 7, 0);

    { path_filestat_set_times(fd, flags, path, path_len, atim:i64, mtim:i64, fst_flags) → errno }
    assert_stub_enosys('path_filestat_set_times returns ENOSYS',
        @wasm.wasi.preview1.path._WASI_path_filestat_set_times, 5, 2);

    { ================================================================== }
    { Tier 4 — poll + sched + proc                                       }
    { ================================================================== }

    { poll_oneoff(in, out, nsubscriptions, nevents) → errno }
    assert_stub_enosys('poll_oneoff returns ENOSYS',
        @wasm.wasi.preview1.poll._WASI_poll_oneoff, 4, 0);

    { proc_raise(sig) → errno }
    assert_stub_enosys('proc_raise returns ENOSYS',
        @wasm.wasi.preview1.poll._WASI_proc_raise, 1, 0);

    { sched_yield() → errno }
    assert_stub_enosys('sched_yield returns ENOSYS',
        @wasm.wasi.preview1.poll._WASI_sched_yield, 0, 0);

    { ================================================================== }
    { Tier 4 — sock_* stubs                                              }
    { ================================================================== }

    { sock_recv(fd, ri_data, ri_data_len, ri_flags, ro_datalen, ro_flags) → errno }
    assert_stub_enosys('sock_recv returns ENOSYS',
        @wasm.wasi.preview1.sock._WASI_sock_recv, 6, 0);

    { sock_send(fd, si_data, si_data_len, si_flags, so_datalen) → errno }
    assert_stub_enosys('sock_send returns ENOSYS',
        @wasm.wasi.preview1.sock._WASI_sock_send, 5, 0);

    { sock_shutdown(fd, how) → errno }
    assert_stub_enosys('sock_shutdown returns ENOSYS',
        @wasm.wasi.preview1.sock._WASI_sock_shutdown, 2, 0);

    { sock_accept(fd, flags, result_fd) → errno }
    assert_stub_enosys('sock_accept returns ENOSYS',
        @wasm.wasi.preview1.sock._WASI_sock_accept, 3, 0);

    test_end;
end;

end.
