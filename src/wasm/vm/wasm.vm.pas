unit wasm.vm;

interface

uses
    wasm.types.builtin, lmemorymanager, console,

    wasm.types.context,
    wasm.vm.opcodes, wasm.vm.opcodes.fc;

procedure init();
function tick(Context : PWASMProcessContext) : TWASMBoolean;

implementation

var
   OpcodeJumpTable : PWASMOpcodeJumpTable;

procedure _WASM_opcode_unimplemented(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm] Unimplemented opcode used');
end;

procedure init();
begin
     {$IFDEF DEBUG_OUTPUT}
     console.writestringln('[wasm.vm] Init');
     {$ENDIF}
     OpcodeJumpTable := PWASMOpcodeJumpTable(kalloc(sizeof(TWASMOpcodeJumpTable)));
     initializeOpcodeJumpTable(@OpcodeJumpTable^[0]);
     wasm.vm.opcodes.fc.init();
end;

function tick(Context : PWASMProcessContext) : TWASMBoolean;
begin
     if Context^.ExecutionState.Running then begin
        if Context^.ExecutionState.IP < Context^.ExecutionState.Limit then
           OpcodeJumpTable^[Context^.ExecutionState.Code[Context^.ExecutionState.IP]](Context)
        else
           Context^.ExecutionState.Running := false;
     end;
     tick:= Context^.ExecutionState.Running;
end;

end.

