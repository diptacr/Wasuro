unit wasm.vm;

interface

uses
    types, lmemorymanager, console,

    wasm.types,
    wasm.vm.opcodes;

procedure init();
function tick(Context : PWASMProcessContext) : Boolean;

implementation

var
   OpcodeJumpTable : TWASMOpcodeJumpTable;

procedure _WASM_opcode_unimplemented(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm] Unimplemented opcode used');
end;

procedure init();
begin
     console.writestringln('[wasm.vm] Init');
     initializeOpcodeJumpTable(@OpcodeJumpTable[0]);
end;

function tick(Context : PWASMProcessContext) : Boolean;
begin
     if Context^.ExecutionState.Running then
        if Context^.ExecutionState.IP < Context^.ExecutionState.Limit then
           OpcodeJumpTable[Context^.ExecutionState.Code[Context^.ExecutionState.IP]](Context);
     tick:= Context^.ExecutionState.Running;
end;

end.

