{ Emulator-layer WASI OS hook implementations.
  This unit provides native hook callbacks for running WASI programs
  on a host OS (Windows/Linux). On bare-metal (Asuro), these would be
  replaced by kernel-level implementations.

  Hooks are registered per-context via PWASMProcessContext.
  This unit has NO knowledge of WASM internals (no stacks, no linear memory). }
unit wasi.emu.hooks;

interface

uses
    wasm.types.context;

procedure register_emu_hooks(ctx : PWASMProcessContext);

implementation

uses
    wasm.types.builtin,
    wasm.wasi.hooks,
    wasm.types.wasi;

{ fd_write: write buf to stdout (fd=1) or stderr (fd=2) }
function emu_fd_write(fd: TWASMUInt32;
                      buf: TWASMPUInt8;
                      len: TWASMUInt32): TWASMUInt32;
var
    i: TWASMUInt32;
begin
    if (fd = 1) or (fd = 2) then begin
        for i := 0 to len - 1 do
            Write(TWASMChar(buf[i]));
        emu_fd_write := len;
    end else
        emu_fd_write := 0;
end;

{ fd_read: stub — no stdin support in emu layer yet }
function emu_fd_read(fd: TWASMUInt32;
                     buf: TWASMPUInt8;
                     len: TWASMUInt32): TWASMUInt32;
begin
    emu_fd_read := 0;
end;

{ fd_close: no-op for emu layer }
function emu_fd_close(fd: TWASMUInt32): TWASMUInt32;
begin
    emu_fd_close := 0; { ESUCCESS }
end;

{ proc_exit: halt the program with the given exit code }
procedure emu_proc_exit(code: TWASMUInt32);
begin
    { The glue layer already sets Running := false and ExitCode.
      On the emu layer, we also halt the host process. }
    halt(code);
end;

{ clock_time_get: return current time in nanoseconds }
function emu_clock_time_get(clock_id: TWASMUInt32;
                            precision: TWASMUInt64;
                            var time: TWASMUInt64): TWASMUInt32;
begin
    { Stub: return 0 nanoseconds. On a real OS we would query the system clock.
      Bare-metal would use RDTSC or PIT. }
    time := 0;
    emu_clock_time_get := WASI_ESUCCESS;
end;

{ clock_res_get: return clock resolution in nanoseconds }
function emu_clock_res_get(clock_id: TWASMUInt32;
                           var resolution: TWASMUInt64): TWASMUInt32;
begin
    { Stub: report 1ms resolution }
    resolution := 1000000;
    emu_clock_res_get := WASI_ESUCCESS;
end;

{ random_get: fill buffer with random bytes }
function emu_random_get(buf: TWASMPUInt8;
                        len: TWASMUInt32): TWASMUInt32;
var
    i: TWASMUInt32;
    state: TWASMUInt32;
begin
    { Simple xorshift PRNG — not cryptographic, but deterministic
      and works without RTL. On bare-metal, use RDRAND. }
    state := 2463534242; { seed }
    for i := 0 to len - 1 do begin
        state := state xor (state shl 13);
        state := state xor (state shr 17);
        state := state xor (state shl 5);
        buf[i] := TWASMUInt8(state and $FF);
    end;
    emu_random_get := WASI_ESUCCESS;
end;

procedure register_emu_hooks(ctx : PWASMProcessContext);
begin
    wasm.wasi.hooks.init_hook_table(ctx);
    wasm.wasi.hooks.register_fd_write(ctx, @emu_fd_write);
    wasm.wasi.hooks.register_fd_read(ctx, @emu_fd_read);
    wasm.wasi.hooks.register_fd_close(ctx, @emu_fd_close);
    wasm.wasi.hooks.register_proc_exit(ctx, @emu_proc_exit);
    wasm.wasi.hooks.register_clock_time_get(ctx, @emu_clock_time_get);
    wasm.wasi.hooks.register_clock_res_get(ctx, @emu_clock_res_get);
    wasm.wasi.hooks.register_random_get(ctx, @emu_random_get);
end;

end.
