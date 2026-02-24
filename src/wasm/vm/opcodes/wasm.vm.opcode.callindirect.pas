unit wasm.vm.opcode.callindirect;

interface

uses wasm.types.context;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);

implementation

uses console;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);
begin
    console.writestringln('[wasm.vm.opcodes] Trap: call_indirect requires table support!');
    Context^.ExecutionState.Running := false;
end;

end.
