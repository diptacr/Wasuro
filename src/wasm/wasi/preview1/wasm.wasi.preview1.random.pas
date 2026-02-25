unit wasm.wasi.preview1.random;

interface

uses
    wasm.types.context;

procedure _WASI_random_get(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ random_get(buf: i32, buf_len: i32) -> errno: i32 }
procedure _WASI_random_get(Context : PWASMProcessContext);
var
    buf_ptr, buf_len: TWASMUInt32;
    native_buf: TWASMPUInt8;
    hooks: PWASIHookTable;
    os: PWASMStack;
    mem: PWasmHeap;
    errno: TWASMUInt32;
    i: TWASMUInt32;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    buf_len := TWASMUInt32(wasm.types.stack.popi32(os));
    buf_ptr := TWASMUInt32(wasm.types.stack.popi32(os));

    { Zero-length request always succeeds regardless of hook }
    if buf_len = 0 then begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
        exit;
    end;

    if hooks^.OnRandomGet <> nil then begin

        { Get native pointer into linear memory }
        native_buf := wasm.types.heap.get_ptr(buf_ptr, mem);
        if native_buf = nil then begin
            wasm.types.stack.pushi32(os, TWASMInt32(WASI_EFAULT));
            exit;
        end;

        errno := hooks^.OnRandomGet(native_buf, buf_len);

        { If buffer crosses page boundary, write byte-by-byte instead }
        { (get_ptr only guarantees within a single page) }
        { For safety, also write back via heap API }
        for i := 0 to buf_len - 1 do
            wasm.types.heap.write_uint8(buf_ptr + i, mem, native_buf[i]);

        wasm.types.stack.pushi32(os, TWASMInt32(errno));
    end else begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
    end;
end;

end.
