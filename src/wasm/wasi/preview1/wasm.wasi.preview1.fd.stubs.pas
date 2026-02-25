{ Stub implementations for WASI fd_* functions not yet supported.
  Each stub pops its arguments from the operand stack and pushes
  WASI_ENOSYS. When real filesystem support is added, individual
  stubs can be extracted into full glue units with OS hook delegation. }
unit wasm.wasi.preview1.fd.stubs;

interface

uses
    wasm.types.context;

procedure _WASI_fd_readdir(Context : PWASMProcessContext);
procedure _WASI_fd_filestat_get(Context : PWASMProcessContext);
procedure _WASI_fd_filestat_set_size(Context : PWASMProcessContext);
procedure _WASI_fd_filestat_set_times(Context : PWASMProcessContext);
procedure _WASI_fd_pread(Context : PWASMProcessContext);
procedure _WASI_fd_pwrite(Context : PWASMProcessContext);
procedure _WASI_fd_sync(Context : PWASMProcessContext);
procedure _WASI_fd_datasync(Context : PWASMProcessContext);
procedure _WASI_fd_tell(Context : PWASMProcessContext);
procedure _WASI_fd_advise(Context : PWASMProcessContext);
procedure _WASI_fd_allocate(Context : PWASMProcessContext);
procedure _WASI_fd_renumber(Context : PWASMProcessContext);
procedure _WASI_fd_fdstat_set_flags(Context : PWASMProcessContext);
procedure _WASI_fd_fdstat_set_rights(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.wasi;

{ fd_readdir(fd:i32, buf:i32, buf_len:i32, cookie:i64, bufused:i32) → errno:i32 }
procedure _WASI_fd_readdir(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { bufused }
    wasm.types.stack.popi64(os);  { cookie }
    wasm.types.stack.popi32(os);  { buf_len }
    wasm.types.stack.popi32(os);  { buf }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_filestat_get(fd:i32, buf:i32) → errno:i32 }
procedure _WASI_fd_filestat_get(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { buf }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_filestat_set_size(fd:i32, size:i64) → errno:i32 }
procedure _WASI_fd_filestat_set_size(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi64(os);  { size }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_filestat_set_times(fd:i32, atim:i64, mtim:i64, fst_flags:i32) → errno:i32 }
procedure _WASI_fd_filestat_set_times(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { fst_flags }
    wasm.types.stack.popi64(os);  { mtim }
    wasm.types.stack.popi64(os);  { atim }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_pread(fd:i32, iovs:i32, iovs_len:i32, offset:i64, nread:i32) → errno:i32 }
procedure _WASI_fd_pread(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { nread }
    wasm.types.stack.popi64(os);  { offset }
    wasm.types.stack.popi32(os);  { iovs_len }
    wasm.types.stack.popi32(os);  { iovs }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_pwrite(fd:i32, iovs:i32, iovs_len:i32, offset:i64, nwritten:i32) → errno:i32 }
procedure _WASI_fd_pwrite(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { nwritten }
    wasm.types.stack.popi64(os);  { offset }
    wasm.types.stack.popi32(os);  { iovs_len }
    wasm.types.stack.popi32(os);  { iovs }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_sync(fd:i32) → errno:i32 }
procedure _WASI_fd_sync(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_datasync(fd:i32) → errno:i32 }
procedure _WASI_fd_datasync(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_tell(fd:i32, offset:i32) → errno:i32 }
procedure _WASI_fd_tell(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { offset }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_advise(fd:i32, offset:i64, len:i64, advice:i32) → errno:i32 }
procedure _WASI_fd_advise(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { advice }
    wasm.types.stack.popi64(os);  { len }
    wasm.types.stack.popi64(os);  { offset }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_allocate(fd:i32, offset:i64, len:i64) → errno:i32 }
procedure _WASI_fd_allocate(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi64(os);  { len }
    wasm.types.stack.popi64(os);  { offset }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_renumber(fd:i32, to:i32) → errno:i32 }
procedure _WASI_fd_renumber(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { to }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_fdstat_set_flags(fd:i32, flags:i32) → errno:i32 }
procedure _WASI_fd_fdstat_set_flags(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { flags }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ fd_fdstat_set_rights(fd:i32, base:i64, inheriting:i64) → errno:i32 }
procedure _WASI_fd_fdstat_set_rights(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi64(os);  { inheriting }
    wasm.types.stack.popi64(os);  { base }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

end.
