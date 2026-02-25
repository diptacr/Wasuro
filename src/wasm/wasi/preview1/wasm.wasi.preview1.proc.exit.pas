unit wasm.wasi.preview1.proc.exit;

interface

uses
    wasm.types.context;

procedure _WASI_proc_exit(Context : PWASMProcessContext);

implementation

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack;

{ proc_exit(code: i32) -> noreturn
  Sets ExitCode and stops execution. Calls OS hook if registered. }
procedure _WASI_proc_exit(Context : PWASMProcessContext);
var
    code: TWASMUInt32;
    hooks: PWASIHookTable;
    os: PWASMStack;
begin
    os := Context^.ExecutionState.Operand_Stack;
    hooks := @Context^.WASIHooks;

    code := TWASMUInt32(wasm.types.stack.popi32(os));

    Context^.ExitCode := code;
    Context^.ExecutionState.Running := false;

    if hooks^.OnProcExit <> nil then
        hooks^.OnProcExit(code);
end;

end.
