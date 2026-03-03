unit wasm.wasi.preview1.fd.write;

interface

uses
    wasm.types.context;

procedure _WASI_fd_write(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi, wasm.vm.io;

{ fd_write(fd: i32, iovs: i32, iovs_len: i32, nwritten: i32) -> errno: i32
  Stack: [fd, iovs_ptr, iovs_len, nwritten_ptr]
  Reads iovec array from linear memory, calls OS hook for each buffer,
  writes total bytes to nwritten_ptr in linear memory, pushes errno. }
procedure _WASI_fd_write(Context : PWASMProcessContext);
var
    fd, iovs_ptr, iovs_len, nwritten_ptr: TWASMUInt32;
    hooks: PWASIHookTable;
    total_written, i: TWASMUInt32;
    buf_ptr, buf_len, written: TWASMUInt32;
    os: PWASMStack;
    mem: PWasmHeap;
    native_buf: TWASMPUInt8;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    { Pop args in reverse order (WASM stack is LIFO) }
    nwritten_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    iovs_len     := TWASMUInt32(wasm.types.stack.popi32(os));
    iovs_ptr     := TWASMUInt32(wasm.types.stack.popi32(os));
    fd           := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnFdWrite = nil then begin
        { No hook registered - return ENOSYS }
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
        exit;
    end;

    total_written := 0;

    for i := 0 to iovs_len - 1 do begin
        { Each iovec is 8 bytes: buf_ptr(u32) + buf_len(u32) }
        wasm.types.heap.read_uint32(iovs_ptr + (i * 8), mem, @buf_ptr);
        wasm.types.heap.read_uint32(iovs_ptr + (i * 8) + 4, mem, @buf_len);

        if buf_len > 0 then begin
            { Get native pointer into linear memory page }
            native_buf := wasm.types.heap.get_ptr(buf_ptr, mem);
            if native_buf <> nil then begin
                written := hooks^.OnFdWrite(fd, native_buf, buf_len);
                total_written := total_written + written;
            end;
        end;
    end;

    { Write total bytes written to nwritten_ptr in linear memory }
    wasm.types.heap.write_uint32(nwritten_ptr, mem, total_written);

    { Push errno (success) }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
end;

end.
