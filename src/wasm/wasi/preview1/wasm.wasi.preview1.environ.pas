unit wasm.wasi.preview1.environ;

interface

uses
    wasm.types.context;

procedure _WASI_environ_sizes_get(Context : PWASMProcessContext);
procedure _WASI_environ_get(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ environ_sizes_get(count: i32, buf_size: i32) -> errno: i32
  Writes count and total buffer size to linear memory. }
procedure _WASI_environ_sizes_get(Context : PWASMProcessContext);
var
    count_ptr, buf_size_ptr: TWASMUInt32;
    os: PWASMStack;
    mem: PWasmHeap;
    hooks: PWASIHookTable;
    count, buf_size, errno: TWASMUInt32;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    buf_size_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    count_ptr    := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnEnvironSizesGet <> nil then begin
        count := 0;
        buf_size := 0;
        errno := hooks^.OnEnvironSizesGet(count, buf_size);
        wasm.types.heap.write_uint32(count_ptr, mem, count);
        wasm.types.heap.write_uint32(buf_size_ptr, mem, buf_size);
        wasm.types.stack.pushi32(os, TWASMInt32(errno));
    end else begin
        { Default: no environment variables }
        wasm.types.heap.write_uint32(count_ptr, mem, 0);
        wasm.types.heap.write_uint32(buf_size_ptr, mem, 0);
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
    end;
end;

{ environ_get(environ: i32, environ_buf: i32) -> errno: i32 }
procedure _WASI_environ_get(Context : PWASMProcessContext);
var
    environ_ptr, environ_buf_ptr: TWASMUInt32;
    os: PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;

    environ_buf_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    environ_ptr     := TWASMUInt32(wasm.types.stack.popi32(os));

    { Default: nothing to copy, return success }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ESUCCESS));
end;

end.
