unit wasm.wasi.preview1.fd.seek;

interface

uses
    wasm.types.context;

procedure _WASI_fd_seek(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ fd_seek(fd: i32, offset: i64, whence: i32, newoffset: i32) -> errno: i32 }
procedure _WASI_fd_seek(Context : PWASMProcessContext);
var
    fd, whence, newoffset_ptr: TWASMUInt32;
    offset: TWASMInt64;
    newoffset: TWASMUInt64;
    hooks: PWASIHookTable;
    os: PWASMStack;
    mem: PWasmHeap;
    errno: TWASMUInt32;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    newoffset_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    whence        := TWASMUInt32(wasm.types.stack.popi32(os));
    offset        := wasm.types.stack.popi64(os);
    fd            := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnFdSeek <> nil then begin
        newoffset := 0;
        errno := hooks^.OnFdSeek(fd, offset, whence, newoffset);
        wasm.types.heap.write_uint64(newoffset_ptr, mem, newoffset);
        wasm.types.stack.pushi32(os, TWASMInt32(errno));
    end else begin
        { stdio fds: seeking is not supported }
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESPIPE));
    end;
end;

end.
