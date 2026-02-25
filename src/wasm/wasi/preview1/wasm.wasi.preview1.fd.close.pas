unit wasm.wasi.preview1.fd.close;

interface

uses
    wasm.types.context;

procedure _WASI_fd_close(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack,
    wasm.types.wasi;

{ fd_close(fd: i32) -> errno: i32 }
procedure _WASI_fd_close(Context : PWASMProcessContext);
var
    fd: TWASMUInt32;
    hooks: PWASIHookTable;
    os: PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    hooks := @Context^.WASIHooks;

    fd := TWASMUInt32(wasm.types.stack.popi32(os));

    if hooks^.OnFdClose <> nil then
        wasm.types.stack.pushi32(os, TWASMInt32(hooks^.OnFdClose(fd)))
    else
        wasm.types.stack.pushi32(os, TWASMInt32(WASI_ENOSYS));
end;

end.
