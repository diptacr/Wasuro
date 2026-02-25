{ WASI path_* operations — stub implementations returning ENOSYS.
  When Asuro's VFS is available, these can be backed by OS hooks
  following the same glue/hook pattern as fd_write. }
unit wasm.wasi.preview1.path;

interface

uses
    wasm.types.context;

procedure _WASI_path_open(Context : PWASMProcessContext);
procedure _WASI_path_filestat_get(Context : PWASMProcessContext);
procedure _WASI_path_create_directory(Context : PWASMProcessContext);
procedure _WASI_path_remove_directory(Context : PWASMProcessContext);
procedure _WASI_path_unlink_file(Context : PWASMProcessContext);
procedure _WASI_path_rename(Context : PWASMProcessContext);
procedure _WASI_path_readlink(Context : PWASMProcessContext);
procedure _WASI_path_link(Context : PWASMProcessContext);
procedure _WASI_path_symlink(Context : PWASMProcessContext);
procedure _WASI_path_filestat_set_times(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.wasi;

{ path_open(fd:i32, dirflags:i32, path:i32, path_len:i32, oflags:i32,
            fs_rights_base:i64, fs_rights_inheriting:i64,
            fdflags:i32, opened_fd:i32) → errno:i32 }
procedure _WASI_path_open(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { opened_fd }
    wasm.types.stack.popi32(os);  { fdflags }
    wasm.types.stack.popi64(os);  { fs_rights_inheriting }
    wasm.types.stack.popi64(os);  { fs_rights_base }
    wasm.types.stack.popi32(os);  { oflags }
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { dirflags }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_filestat_get(fd:i32, flags:i32, path:i32, path_len:i32, buf:i32) → errno:i32 }
procedure _WASI_path_filestat_get(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { buf }
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { flags }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_create_directory(fd:i32, path:i32, path_len:i32) → errno:i32 }
procedure _WASI_path_create_directory(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_remove_directory(fd:i32, path:i32, path_len:i32) → errno:i32 }
procedure _WASI_path_remove_directory(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_unlink_file(fd:i32, path:i32, path_len:i32) → errno:i32 }
procedure _WASI_path_unlink_file(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_rename(fd:i32, old_path:i32, old_len:i32, new_fd:i32, new_path:i32, new_len:i32) → errno:i32 }
procedure _WASI_path_rename(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { new_len }
    wasm.types.stack.popi32(os);  { new_path }
    wasm.types.stack.popi32(os);  { new_fd }
    wasm.types.stack.popi32(os);  { old_len }
    wasm.types.stack.popi32(os);  { old_path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_readlink(fd:i32, path:i32, path_len:i32, buf:i32, buf_len:i32, bufused:i32) → errno:i32 }
procedure _WASI_path_readlink(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { bufused }
    wasm.types.stack.popi32(os);  { buf_len }
    wasm.types.stack.popi32(os);  { buf }
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_link(old_fd:i32, old_flags:i32, old_path:i32, old_path_len:i32,
            new_fd:i32, new_path:i32, new_path_len:i32) → errno:i32 }
procedure _WASI_path_link(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { new_path_len }
    wasm.types.stack.popi32(os);  { new_path }
    wasm.types.stack.popi32(os);  { new_fd }
    wasm.types.stack.popi32(os);  { old_path_len }
    wasm.types.stack.popi32(os);  { old_path }
    wasm.types.stack.popi32(os);  { old_flags }
    wasm.types.stack.popi32(os);  { old_fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_symlink(old_path:i32, old_path_len:i32, fd:i32, new_path:i32, new_path_len:i32) → errno:i32 }
procedure _WASI_path_symlink(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { new_path_len }
    wasm.types.stack.popi32(os);  { new_path }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.popi32(os);  { old_path_len }
    wasm.types.stack.popi32(os);  { old_path }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ path_filestat_set_times(fd:i32, flags:i32, path:i32, path_len:i32,
                          atim:i64, mtim:i64, fst_flags:i32) → errno:i32 }
procedure _WASI_path_filestat_set_times(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { fst_flags }
    wasm.types.stack.popi64(os);  { mtim }
    wasm.types.stack.popi64(os);  { atim }
    wasm.types.stack.popi32(os);  { path_len }
    wasm.types.stack.popi32(os);  { path }
    wasm.types.stack.popi32(os);  { flags }
    wasm.types.stack.popi32(os);  { fd }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

end.
