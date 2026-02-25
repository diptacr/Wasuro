{ WASI poll and scheduler stubs. }
unit wasm.wasi.preview1.poll;

interface

uses
    wasm.types.context;

procedure _WASI_poll_oneoff(Context : PWASMProcessContext);
procedure _WASI_proc_raise(Context : PWASMProcessContext);
procedure _WASI_sched_yield(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.wasi;

{ poll_oneoff(in:i32, out:i32, nsubscriptions:i32, nevents:i32) → errno:i32 }
procedure _WASI_poll_oneoff(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { nevents }
    wasm.types.stack.popi32(os);  { nsubscriptions }
    wasm.types.stack.popi32(os);  { out }
    wasm.types.stack.popi32(os);  { in }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ proc_raise(sig:i32) → errno:i32 }
procedure _WASI_proc_raise(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    wasm.types.stack.popi32(os);  { sig }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

{ sched_yield() → errno:i32 }
procedure _WASI_sched_yield(Context : PWASMProcessContext);
var os : PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    { No arguments to pop }
    wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

end.
