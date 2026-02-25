program WASURO;

uses
    sysutils,
    console,
    wasm.types.builtin,
    wasm.types.context,
    wasm,

    { Emu-layer OS hooks }
    wasi.emu.hooks

    {$IFDEF RUN_TESTS}
    , wasm.test
    , wasm.test.framework
    {$ENDIF}
    ;

var
   Context : PWASMProcessContext;
   ModuleSize     : Int64;
   ModuleBuffer   : TWASMPUInt8;
   ModuleFile     : File;

begin
    {$IFDEF RUN_TESTS}
    wasm.wasm_init;
    wasm.test.run_all_tests;
    halt(wasm.test.framework.FailedTests);
    {$ELSE}
    {$IFDEF DEBUG_OUTPUT}
    console.writestringln('WASURO - WebAssembly Runtime in Object Pascal');
    {$ENDIF}
    wasm.wasm_init;

    if ParamCount > 0 then begin
        if not FileExists(ParamStr(1)) then begin
            console.writestringln('File not found.');
            halt(1);
        end;
        Assign(ModuleFile, ParamStr(1));
        Reset(ModuleFile, 1);
        ModuleSize := FileSize(ModuleFile);
        GetMem(ModuleBuffer, ModuleSize);
        BlockRead(ModuleFile, ModuleBuffer^, ModuleSize);
        Close(ModuleFile);
        {$IFDEF DEBUG_OUTPUT}
         write('Module loaded from file: ');
         writeln(ParamStr(1));
        {$ENDIF}

        { Load, configure, and run the WASM module }
        Context := wasm.wasm_load(ModuleBuffer, TWASMPUInt8(ModuleBuffer + ModuleSize));

        if not Context^.ValidBinary then begin
            console.writestringln('Error: Invalid WASM binary.');
            halt(1);
        end;

        { Register emu-layer OS hooks and WASI preview1 into context }
        wasi.emu.hooks.register_emu_hooks(Context);
        wasm.wasm_register_wasi_preview1(Context);

        { Find _start and run to completion }
        if not wasm.wasm_start(Context) then begin
            console.writestringln('No _start export found.');
            halt(1);
        end;

        {$IFDEF DEBUG_OUTPUT}
        wasm.wasm_dump_state(Context);
        {$ENDIF}

        FreeMem(ModuleBuffer);
        halt(Context^.ExitCode);
    end else begin
        console.writestringln('Usage: WASURO <module.wasm>');
        halt(1);
    end;
    {$ENDIF}
end.

