unit wasm.vm.opcode.unreachable;

interface

uses wasm.types.context;

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);

implementation

uses console;

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] Trap: unreachable executed!');
     Context^.ExecutionState.Running := false;
end;

end.
