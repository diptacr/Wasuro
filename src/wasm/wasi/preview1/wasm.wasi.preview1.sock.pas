{ WASI socket stubs — always return ENOSYS.
  Networking is not a target for bare-metal Asuro, but these must
  be present so that WASI binaries that import them don't trap on
  unresolved imports. }
unit wasm.wasi.preview1.sock;

interface

uses
    wasm.types.context;

procedure _WASI_sock_recv(Context : PWASMProcessContext);
procedure _WASI_sock_send(Context : PWASMProcessContext);
procedure _WASI_sock_shutdown(Context : PWASMProcessContext);
procedure _WASI_sock_accept(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.wasi;

{ sock_recv(fd:i32, ri_data:i32, ri_data_len:i32, ri_flags:i32,
            ro_datalen:i32, ro_flags:i32) → errno:i32 }
procedure _WASI_sock_recv(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { ro_flags }
    wasm.types.stack.popi32(os);  { ro_datalen }
    wasm.types.stack.popi32(os);  { ri_flags }
    wasm.types.stack.popi32(os);  { ri_data_len }
    wasm.types.stack.popi32(os);  { ri_data }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ sock_send(fd:i32, si_data:i32, si_data_len:i32, si_flags:i32,
            so_datalen:i32) → errno:i32 }
procedure _WASI_sock_send(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { so_datalen }
    wasm.types.stack.popi32(os);  { si_flags }
    wasm.types.stack.popi32(os);  { si_data_len }
    wasm.types.stack.popi32(os);  { si_data }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ sock_shutdown(fd:i32, how:i32) → errno:i32 }
procedure _WASI_sock_shutdown(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { how }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ sock_accept(fd:i32, flags:i32, result_fd:i32) → errno:i32 }
procedure _WASI_sock_accept(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { result_fd }
    wasm.types.stack.popi32(os);  { flags }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

end.
