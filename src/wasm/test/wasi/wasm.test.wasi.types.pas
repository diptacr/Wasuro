unit wasm.test.wasi.types;

interface

procedure run;

implementation

uses
    wasm.types.builtin,
    wasm.types.wasi,
    wasm.test.framework;

procedure run;
begin
    test_begin('wasi.types');

    { Verify key errno constants }
    assert_u32('WASI_ESUCCESS = 0',    WASI_ESUCCESS, 0);
    assert_u32('WASI_EBADF = 8',       WASI_EBADF, 8);
    assert_u32('WASI_EINVAL = 28',     WASI_EINVAL, 28);
    assert_u32('WASI_ENOSYS = 52',     WASI_ENOSYS, 52);
    assert_u32('WASI_ENOTCAPABLE = 76', WASI_ENOTCAPABLE, 76);
    assert_u32('WASI_ESPIPE = 70',     WASI_ESPIPE, 70);

    { Verify standard fd constants }
    assert_u32('WASI_FD_STDIN = 0',    WASI_FD_STDIN, 0);
    assert_u32('WASI_FD_STDOUT = 1',   WASI_FD_STDOUT, 1);
    assert_u32('WASI_FD_STDERR = 2',   WASI_FD_STDERR, 2);

    { Verify iovec layout - size should be 8 bytes (two u32s) }
    assert_u32('TWASIIoVec size = 8', sizeof(TWASIIoVec), 8);

    test_end;
end;

end.
