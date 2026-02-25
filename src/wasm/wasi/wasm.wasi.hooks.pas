unit wasm.wasi.hooks;
{ Per-context WASI hook registration.
  Hook types (TWASIHookTable etc.) are defined in wasm.types.context.
  Each TWASMProcessContext owns its own hook table. }

interface

uses
    wasm.types.context;

procedure init_hook_table(ctx : PWASMProcessContext);

procedure register_fd_write(ctx : PWASMProcessContext; hook: TWASIFdWriteHook);
procedure register_fd_read(ctx : PWASMProcessContext; hook: TWASIFdReadHook);
procedure register_fd_close(ctx : PWASMProcessContext; hook: TWASIFdCloseHook);
procedure register_fd_seek(ctx : PWASMProcessContext; hook: TWASIFdSeekHook);
procedure register_proc_exit(ctx : PWASMProcessContext; hook: TWASIProcExitHook);
procedure register_clock_time_get(ctx : PWASMProcessContext; hook: TWASIClockTimeGetHook);
procedure register_clock_res_get(ctx : PWASMProcessContext; hook: TWASIClockResGetHook);
procedure register_random_get(ctx : PWASMProcessContext; hook: TWASIRandomGetHook);
procedure register_args_sizes_get(ctx : PWASMProcessContext; hook: TWASIArgsSizesGetHook);
procedure register_args_get(ctx : PWASMProcessContext; hook: TWASIArgsGetHook);
procedure register_environ_sizes_get(ctx : PWASMProcessContext; hook: TWASIEnvironSizesGetHook);
procedure register_environ_get(ctx : PWASMProcessContext; hook: TWASIEnvironGetHook);

implementation

procedure init_hook_table(ctx : PWASMProcessContext);
begin
    ctx^.WASIHooks.OnFdWrite         := nil;
    ctx^.WASIHooks.OnFdRead          := nil;
    ctx^.WASIHooks.OnFdClose         := nil;
    ctx^.WASIHooks.OnFdSeek          := nil;
    ctx^.WASIHooks.OnProcExit        := nil;
    ctx^.WASIHooks.OnClockTimeGet    := nil;
    ctx^.WASIHooks.OnClockResGet     := nil;
    ctx^.WASIHooks.OnRandomGet       := nil;
    ctx^.WASIHooks.OnArgsSizesGet    := nil;
    ctx^.WASIHooks.OnArgsGet         := nil;
    ctx^.WASIHooks.OnEnvironSizesGet := nil;
    ctx^.WASIHooks.OnEnvironGet      := nil;
end;

procedure register_fd_write(ctx : PWASMProcessContext; hook: TWASIFdWriteHook);
begin
    ctx^.WASIHooks.OnFdWrite := hook;
end;

procedure register_fd_read(ctx : PWASMProcessContext; hook: TWASIFdReadHook);
begin
    ctx^.WASIHooks.OnFdRead := hook;
end;

procedure register_fd_close(ctx : PWASMProcessContext; hook: TWASIFdCloseHook);
begin
    ctx^.WASIHooks.OnFdClose := hook;
end;

procedure register_fd_seek(ctx : PWASMProcessContext; hook: TWASIFdSeekHook);
begin
    ctx^.WASIHooks.OnFdSeek := hook;
end;

procedure register_proc_exit(ctx : PWASMProcessContext; hook: TWASIProcExitHook);
begin
    ctx^.WASIHooks.OnProcExit := hook;
end;

procedure register_clock_time_get(ctx : PWASMProcessContext; hook: TWASIClockTimeGetHook);
begin
    ctx^.WASIHooks.OnClockTimeGet := hook;
end;

procedure register_clock_res_get(ctx : PWASMProcessContext; hook: TWASIClockResGetHook);
begin
    ctx^.WASIHooks.OnClockResGet := hook;
end;

procedure register_random_get(ctx : PWASMProcessContext; hook: TWASIRandomGetHook);
begin
    ctx^.WASIHooks.OnRandomGet := hook;
end;

procedure register_args_sizes_get(ctx : PWASMProcessContext; hook: TWASIArgsSizesGetHook);
begin
    ctx^.WASIHooks.OnArgsSizesGet := hook;
end;

procedure register_args_get(ctx : PWASMProcessContext; hook: TWASIArgsGetHook);
begin
    ctx^.WASIHooks.OnArgsGet := hook;
end;

procedure register_environ_sizes_get(ctx : PWASMProcessContext; hook: TWASIEnvironSizesGetHook);
begin
    ctx^.WASIHooks.OnEnvironSizesGet := hook;
end;

procedure register_environ_get(ctx : PWASMProcessContext; hook: TWASIEnvironGetHook);
begin
    ctx^.WASIHooks.OnEnvironGet := hook;
end;

end.
