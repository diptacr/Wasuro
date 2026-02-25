unit wasm.wasi.preview1.clock;

interface

uses
    wasm.types.context;

procedure _WASI_clock_time_get(Context : PWASMProcessContext);
procedure _WASI_clock_res_get(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.heap,
    wasm.types.wasi;

{ clock_time_get(id: i32, precision: i64, time: i32) -> errno: i32 }
procedure _WASI_clock_time_get(Context : PWASMProcessContext);
var
    clock_id, time_ptr: TWASMUInt32;
    precision: TWASMUInt64;
    time: TWASMUInt64;
    hooks: PWASIHookTable;
    os: PWASMStack;
    mem: PWasmHeap;
    errno: TWASMUInt32;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    time_ptr  := TWASMUInt32(wasm.types.stack.popi32(os));
    precision := TWASMUInt64(wasm.types.stack.popi64(os));
    clock_id  := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnClockTimeGet <> nil then begin
        time := 0;
        errno := hooks^.OnClockTimeGet(clock_id, precision, time);
        wasm.types.heap.write_uint64(time_ptr, mem, time);
        wasm.types.stack.pushi32(os, TWASMInt32(errno));
    end else begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
    end;
end;

{ clock_res_get(id: i32, resolution: i32) -> errno: i32 }
procedure _WASI_clock_res_get(Context : PWASMProcessContext);
var
    clock_id, resolution_ptr: TWASMUInt32;
    resolution: TWASMUInt64;
    hooks: PWASIHookTable;
    os: PWASMStack;
    mem: PWasmHeap;
    errno: TWASMUInt32;
begin
    os := Context^.ExecutionState.Operand_Stack;
    mem := Context^.ExecutionState.Memory;
    hooks := @Context^.WASIHooks;

    resolution_ptr := TWASMUInt32(wasm.types.stack.popi32(os));
    clock_id       := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnClockResGet <> nil then begin
        resolution := 0;
        errno := hooks^.OnClockResGet(clock_id, resolution);
        wasm.types.heap.write_uint64(resolution_ptr, mem, resolution);
        wasm.types.stack.pushi32(os, TWASMInt32(errno));
    end else begin
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
    end;
end;

end.
