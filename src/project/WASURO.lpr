program WASURO;

uses
    sysutils,

    console,

    types,

    wasm.types,
    wasm.parser,
    wasm.vm, wasm.test.binary,
    wasm.types.stack;

var
   Context : PWASMProcessContext;

begin
    writestringln('[main] Initializing VM');
    wasm.vm.init();

    writestringln('[main] Parsing WASM Binary');
    Context:= wasm.parser.parse(@wasm.test.binary.TEST_BINARY_1[0], puint8(@wasm.test.binary.TEST_BINARY_1[0] + $26));

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
end.

