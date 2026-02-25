unit wasm.wasi.preview1.fd.fdstat;

interface

uses
    wasm.types.context;

procedure _WASI_fd_fdstat_get(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ fd_fdstat_get(fd: i32, buf: i32) -> errno: i32
  Writes TWASIFdStat to buf in linear memory.
  For stdio fds: CHARACTER_DEVICE, no flags, all rights. }
procedure _WASI_fd_fdstat_get(Context : PWASMProcessContext);
var
    fd, buf_ptr: TWASMUInt32;
    os: PWASMStack;
    mem: PWasmHeap;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;

    buf_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    fd      := TWASMUInt32(wasm.types.stack.popi32(os));

    if (fd = WASI_FD_STDIN) or (fd = WASI_FD_STDOUT) or (fd = WASI_FD_STDERR) then begin
        { fdstat layout (24 bytes):
          offset 0: filetype (u8)
          offset 2: fdflags (u16)
          offset 8: fs_rights_base (u64)
          offset 16: fs_rights_inheriting (u64) }
        wasm.types.heap.write_uint8(buf_ptr, mem, WASI_FILETYPE_CHARACTER_DEVICE);
        wasm.types.heap.write_uint8(buf_ptr + 1, mem, 0); { padding }
        wasm.types.heap.write_uint16(buf_ptr + 2, mem, 0); { fdflags = 0 }
        wasm.types.heap.write_uint32(buf_ptr + 4, mem, 0); { padding }
        wasm.types.heap.write_uint64(buf_ptr + 8, mem, TWASMUInt64($FFFFFFFFFFFFFFFF)); { all rights }
        wasm.types.heap.write_uint64(buf_ptr + 16, mem, TWASMUInt64($FFFFFFFFFFFFFFFF)); { inheriting }
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
    end else begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_EBADF));
    end;
end;

end.
