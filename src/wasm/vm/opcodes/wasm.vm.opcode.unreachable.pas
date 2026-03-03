unit wasm.vm.opcode.unreachable;

interface

uses wasm.types.context;

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io;

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);
begin
     wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: unreachable executed!');
     Context^.ExecutionState.Running := false;
end;

end.
