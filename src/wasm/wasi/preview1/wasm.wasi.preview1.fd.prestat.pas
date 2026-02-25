unit wasm.wasi.preview1.fd.prestat;

interface

uses
    wasm.types.context;

procedure _WASI_fd_prestat_get(Context : PWASMProcessContext);
procedure _WASI_fd_prestat_dir_name(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack,
    wasm.types.wasi;

{ fd_prestat_get(fd: i32, buf: i32) -> errno: i32
  For Phase 2: return EBADF for all fds (no pre-opened dirs) }
procedure _WASI_fd_prestat_get(Context : PWASMProcessContext);
var
    fd, buf_ptr: TWASMUInt32;
    os: PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;

    buf_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    fd      := TWASMUInt32(wasm.types.stack.popi32(os));

    { No pre-opened directories yet - return EBADF }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_EBADF));
end;

{ fd_prestat_dir_name(fd: i32, path: i32, path_len: i32) -> errno: i32 }
procedure _WASI_fd_prestat_dir_name(Context : PWASMProcessContext);
var
    fd, path_ptr, path_len: TWASMUInt32;
    os: PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;

    path_len := TWASMUInt32(wasm.types.stack.popi32(os));
    path_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    fd       := TWASMUInt32(wasm.types.stack.popi32(os));

    { No pre-opened directories yet - return EBADF }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_EBADF));
end;

end.
