program WASURO;

uses
    sysutils,

    console,

    types,

    wasm.types,
    wasm.parser,
    wasm.vm, wasm.test.binary.return42,
    wasm.types.stack
    {$IFDEF RUN_TESTS}
    , wasm.test
    , wasm.test.framework
    {$ENDIF}
    ;

var
   Context : PWASMProcessContext;

begin
    {$IFDEF RUN_TESTS}
    wasm.vm.init();
    wasm.test.run_all_tests;
    halt(wasm.test.framework.FailedTests);
    {$ELSE}
    writestringln('[main] Initializing VM');
    wasm.vm.init();

    writestringln('[main] Parsing WASM Binary');
    Context:= wasm.parser.parse(@wasm.test.binary.return42.BINARY[0], puint8(@wasm.test.binary.return42.BINARY[0] + wasm.test.binary.return42.BINARY_SIZE));

    writestringln('[main] Running...');
    Context^.ExecutionState.Running:= true;
    while (wasm.vm.tick(Context)) do;
    writestringln('[main] Finished Execution');
    writestring('[main] Returns: ');
    while Context^.ExecutionState.Operand_Stack^.Top > 0 do begin
        write(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack),', ');
    end;
    writeln();
    while true do sleep(1000);
    {$ENDIF}
end.

