unit wasm.vm.opcode.nop;

interface

uses wasm.types.context;

procedure _WASM_opcode_NopOp(Context : PWASMProcessContext);

implementation

procedure _WASM_opcode_NopOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
end;

end.
