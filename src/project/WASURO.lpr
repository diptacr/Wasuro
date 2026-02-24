program WASURO;

uses
    sysutils,

    console,

    wasm.types.builtin,
    wasm.types.context,
    wasm.types.stack,
    wasm.parser,
    wasm.vm
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
    wasm.vm.init();
    wasm.test.run_all_tests;
    halt(wasm.test.framework.FailedTests);
    {$ELSE}
    console.writestringln('WASURO - WebAssembly Runtime in Object Pascal');
    wasm.vm.init();
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
        console.writestringln('Module loaded.');
        Context := wasm.parser.parse(ModuleBuffer, TWASMPUInt8(ModuleBuffer + ModuleSize));
        while wasm.vm.tick(Context) do ;
        console.writestringln('Execution finished.');
        console.writestringln('');
        console.writestringln('--- VM State ---');
        writeln('IP:      ', Context^.ExecutionState.IP);
        writeln('Running: ', Context^.ExecutionState.Running);
        writeln('');
        writeln('Operand Stack (', Context^.ExecutionState.Operand_Stack^.Top, ' entries):');
        if Context^.ExecutionState.Operand_Stack^.Top > 0 then
            wasm.types.stack.walk(Context^.ExecutionState.Operand_Stack)
        else
            console.writestringln('  (empty)');
        writeln('');
        writeln('Control Stack (', Context^.ExecutionState.Control_Stack^.Top, ' entries):');
        if Context^.ExecutionState.Control_Stack^.Top > 0 then
            wasm.types.stack.walk(Context^.ExecutionState.Control_Stack)
        else
            console.writestringln('  (empty)');
        console.writestringln('----------------');
        FreeMem(ModuleBuffer);
    end else begin
        console.writestringln('Usage: WASURO <module.wasm>');
        halt(1);
    end;
    {$ENDIF}
end.

