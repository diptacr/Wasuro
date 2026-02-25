unit wasm;
{ Top-level glue/trampoline unit for the WASURO WebAssembly VM.
  A caller only needs this unit (plus wasm.types.context for the
  PWASMProcessContext pointer) to load, configure, and execute
  a WASM module.

  Typical usage:
    wasm_init;
    ctx := wasm_load(buf, buf_end);
    wasm_set_fd_write(ctx, @my_write);
    wasm_register_wasi_preview1(ctx);
    wasm_start(ctx);
}

interface

uses
    wasm.types.builtin,
    wasm.types.context;

{ ---- One-time initialization ----------------------------------------- }

{ Initialize the VM opcode dispatch table. Call once at program start. }
procedure wasm_init;

{ ---- Module loading -------------------------------------------------- }

{ Parse a WASM binary from [buffer .. buffer_end).
  Returns a fully initialized PWASMProcessContext.
  Check ctx^.ValidBinary for parse success. }
function wasm_load(buffer, buffer_end : TWASMPUInt8) : PWASMProcessContext;

{ ---- WASI hook registration ----------------------------------------- }

{ Set individual WASI OS hooks on a context.
  These are called by the WASI preview1 glue when guest code invokes
  the corresponding WASI syscall. }
procedure wasm_set_fd_write(ctx : PWASMProcessContext; hook : TWASIFdWriteHook);
procedure wasm_set_fd_read(ctx : PWASMProcessContext; hook : TWASIFdReadHook);
procedure wasm_set_fd_close(ctx : PWASMProcessContext; hook : TWASIFdCloseHook);
procedure wasm_set_fd_seek(ctx : PWASMProcessContext; hook : TWASIFdSeekHook);
procedure wasm_set_proc_exit(ctx : PWASMProcessContext; hook : TWASIProcExitHook);
procedure wasm_set_clock_time_get(ctx : PWASMProcessContext; hook : TWASIClockTimeGetHook);
procedure wasm_set_clock_res_get(ctx : PWASMProcessContext; hook : TWASIClockResGetHook);
procedure wasm_set_random_get(ctx : PWASMProcessContext; hook : TWASIRandomGetHook);
procedure wasm_set_args_sizes_get(ctx : PWASMProcessContext; hook : TWASIArgsSizesGetHook);
procedure wasm_set_args_get(ctx : PWASMProcessContext; hook : TWASIArgsGetHook);
procedure wasm_set_environ_sizes_get(ctx : PWASMProcessContext; hook : TWASIEnvironSizesGetHook);
procedure wasm_set_environ_get(ctx : PWASMProcessContext; hook : TWASIEnvironGetHook);

{ ---- WASI preview1 bulk registration -------------------------------- }

{ Register all 46 WASI snapshot_preview1 glue functions into the
  context's host function registry. }
procedure wasm_register_wasi_preview1(ctx : PWASMProcessContext);

{ ---- Custom host function registration ------------------------------ }

{ Register a custom host function (import) into the context.
  module_name / field_name identify the import; callback is invoked
  when the guest calls the import. }
procedure wasm_register_host_func(ctx : PWASMProcessContext;
                                  module_name, field_name : TWASMPChar;
                                  callback : TWASMHostFunc);

{ ---- Import resolution ----------------------------------------------- }

{ Resolve all imports in the module against the registered host
  functions. Call after all register_* calls and before execution. }
procedure wasm_resolve_imports(ctx : PWASMProcessContext);

{ ---- Execution ------------------------------------------------------- }

{ Locate the _start export, set up the call frame (locals, control
  stack), resolve imports, and run to completion.
  Returns true if execution completed, false if _start was not found
  or the binary was invalid. }
function wasm_start(ctx : PWASMProcessContext) : TWASMBoolean;

{ Locate the _start export and set up the call frame, but do NOT
  begin execution. Use wasm_tick to drive execution manually.
  Returns true if _start was found and the context is ready. }
function wasm_prepare_start(ctx : PWASMProcessContext) : TWASMBoolean;

{ Execute a single VM instruction. Returns true while the context
  is still running (i.e. more instructions to process). }
function wasm_tick(ctx : PWASMProcessContext) : TWASMBoolean;

{ ---- Diagnostics ----------------------------------------------------- }

{ Dump the current VM state (IP, running, exit code, stacks) to
  the console. Useful for post-execution diagnostics. }
procedure wasm_dump_state(ctx : PWASMProcessContext);

implementation

uses
    console,
    wasm.types.stack,
    wasm.parser,
    wasm.vm,
    wasm.vm.setup,
    wasm.wasi.hooks,
    wasm.wasi.registry,
    wasm.wasi.preview1;

{ ---- One-time initialization ----------------------------------------- }

procedure wasm_init;
begin
    wasm.vm.init;
end;

{ ---- Module loading -------------------------------------------------- }

function wasm_load(buffer, buffer_end : TWASMPUInt8) : PWASMProcessContext;
begin
    wasm_load := wasm.parser.parse(buffer, buffer_end);
end;

{ ---- WASI hook registration ----------------------------------------- }

procedure wasm_set_fd_write(ctx : PWASMProcessContext; hook : TWASIFdWriteHook);
begin
    wasm.wasi.hooks.register_fd_write(ctx, hook);
end;

procedure wasm_set_fd_read(ctx : PWASMProcessContext; hook : TWASIFdReadHook);
begin
    wasm.wasi.hooks.register_fd_read(ctx, hook);
end;

procedure wasm_set_fd_close(ctx : PWASMProcessContext; hook : TWASIFdCloseHook);
begin
    wasm.wasi.hooks.register_fd_close(ctx, hook);
end;

procedure wasm_set_fd_seek(ctx : PWASMProcessContext; hook : TWASIFdSeekHook);
begin
    wasm.wasi.hooks.register_fd_seek(ctx, hook);
end;

procedure wasm_set_proc_exit(ctx : PWASMProcessContext; hook : TWASIProcExitHook);
begin
    wasm.wasi.hooks.register_proc_exit(ctx, hook);
end;

procedure wasm_set_clock_time_get(ctx : PWASMProcessContext; hook : TWASIClockTimeGetHook);
begin
    wasm.wasi.hooks.register_clock_time_get(ctx, hook);
end;

procedure wasm_set_clock_res_get(ctx : PWASMProcessContext; hook : TWASIClockResGetHook);
begin
    wasm.wasi.hooks.register_clock_res_get(ctx, hook);
end;

procedure wasm_set_random_get(ctx : PWASMProcessContext; hook : TWASIRandomGetHook);
begin
    wasm.wasi.hooks.register_random_get(ctx, hook);
end;

procedure wasm_set_args_sizes_get(ctx : PWASMProcessContext; hook : TWASIArgsSizesGetHook);
begin
    wasm.wasi.hooks.register_args_sizes_get(ctx, hook);
end;

procedure wasm_set_args_get(ctx : PWASMProcessContext; hook : TWASIArgsGetHook);
begin
    wasm.wasi.hooks.register_args_get(ctx, hook);
end;

procedure wasm_set_environ_sizes_get(ctx : PWASMProcessContext; hook : TWASIEnvironSizesGetHook);
begin
    wasm.wasi.hooks.register_environ_sizes_get(ctx, hook);
end;

procedure wasm_set_environ_get(ctx : PWASMProcessContext; hook : TWASIEnvironGetHook);
begin
    wasm.wasi.hooks.register_environ_get(ctx, hook);
end;

{ ---- WASI preview1 bulk registration -------------------------------- }

procedure wasm_register_wasi_preview1(ctx : PWASMProcessContext);
begin
    wasm.wasi.preview1.register_all(ctx);
end;

{ ---- Custom host function registration ------------------------------ }

procedure wasm_register_host_func(ctx : PWASMProcessContext;
                                  module_name, field_name : TWASMPChar;
                                  callback : TWASMHostFunc);
begin
    wasm.wasi.registry.register_host_func(ctx, module_name, field_name, callback);
end;

{ ---- Import resolution ----------------------------------------------- }

procedure wasm_resolve_imports(ctx : PWASMProcessContext);
begin
    wasm.wasi.registry.resolve_imports(ctx);
end;

{ ---- Execution ------------------------------------------------------- }

function wasm_start(ctx : PWASMProcessContext) : TWASMBoolean;
begin
    if not ctx^.ValidBinary then begin
        wasm_start := false;
        exit;
    end;

    { Resolve any registered imports }
    wasm.wasi.registry.resolve_imports(ctx);

    { Find _start and set up call frame }
    if not wasm.vm.setup.find_start(ctx) then begin
        wasm_start := false;
        exit;
    end;

    { Run to completion }
    while wasm.vm.tick(ctx) do ;

    wasm_start := true;
end;

function wasm_prepare_start(ctx : PWASMProcessContext) : TWASMBoolean;
begin
    if not ctx^.ValidBinary then begin
        wasm_prepare_start := false;
        exit;
    end;

    wasm.wasi.registry.resolve_imports(ctx);
    wasm_prepare_start := wasm.vm.setup.find_start(ctx);
end;

function wasm_tick(ctx : PWASMProcessContext) : TWASMBoolean;
begin
    wasm_tick := wasm.vm.tick(ctx);
end;

{ ---- Diagnostics ----------------------------------------------------- }

procedure wasm_dump_state(ctx : PWASMProcessContext);
begin
    console.writestringln('');
    console.writestringln('Execution finished.');
    console.writestringln('');
    console.writestringln('--- VM State ---');
    console.writestring('IP:      ');
    console.writeintlnWND(ctx^.ExecutionState.IP, 0);
    console.writestring('Running: ');
    if ctx^.ExecutionState.Running then
        console.writestringln('true')
    else
        console.writestringln('false');
    console.writestring('ExitCode:');
    console.writeintlnWND(ctx^.ExitCode, 0);
    console.writestringln('');
    console.writestring('Operand Stack (');
    console.writeintWND(ctx^.ExecutionState.Operand_Stack^.Top, 0);
    console.writestringln(' entries):');
    if ctx^.ExecutionState.Operand_Stack^.Top > 0 then
        wasm.types.stack.walk(ctx^.ExecutionState.Operand_Stack)
    else
        console.writestringln('  (empty)');
    console.writestringln('');
    console.writestring('Control Stack (');
    console.writeintWND(ctx^.ExecutionState.Control_Stack^.Top, 0);
    console.writestringln(' entries):');
    if ctx^.ExecutionState.Control_Stack^.Top > 0 then
        wasm.types.stack.walk(ctx^.ExecutionState.Control_Stack)
    else
        console.writestringln('  (empty)');
    console.writestringln('----------------');
end;

end.

