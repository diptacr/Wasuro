unit wasm.wasi.preview1.fd.read;

interface

uses
    wasm.types.context;

procedure _WASI_fd_read(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ fd_read(fd: i32, iovs: i32, iovs_len: i32, nread: i32) -> errno: i32 }
procedure _WASI_fd_read(Context : PWASMProcessContext);
var
    fd, iovs_ptr, iovs_len, nread_ptr: TWASMUInt32;
    hooks: PWASIHookTable;
    total_read, i: TWASMUInt32;
    buf_ptr, buf_len, bytes_read: TWASMUInt32;
    os: PWASMStack;
    mem: PWasmHeap;
    native_buf: TWASMPUInt8;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    nread_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    iovs_len  := TWASMUInt32(wasm.types.stack.popi32(os));
    iovs_ptr  := TWASMUInt32(wasm.types.stack.popi32(os));
    fd        := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnFdRead = nil then begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
        exit;
    end;

    total_read := 0;

    for i := 0 to iovs_len - 1 do begin
        wasm.types.heap.read_uint32(iovs_ptr + (i * 8), mem, @buf_ptr);
        wasm.types.heap.read_uint32(iovs_ptr + (i * 8) + 4, mem, @buf_len);

        if buf_len > 0 then begin
            native_buf := wasm.types.heap.get_ptr(buf_ptr, mem);
            if native_buf <> nil then begin
                bytes_read := hooks^.OnFdRead(fd, native_buf, buf_len);
                total_read := total_read + bytes_read;
                if bytes_read < buf_len then break; { short read }
            end;
        end;
    end;

    wasm.types.heap.write_uint32(nread_ptr, mem, total_read);
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
end;

end.
