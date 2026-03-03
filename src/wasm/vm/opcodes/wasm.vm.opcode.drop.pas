unit wasm.vm.opcode.drop;

interface

uses wasm.types.context;

procedure _WASM_opcode_DropOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io;

procedure _WASM_opcode_DropOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
     if Context^.ExecutionState.Operand_Stack^.Top > 0 then
        Dec(Context^.ExecutionState.Operand_Stack^.Top)
     else begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes.dropop] Stack underflow!');
        Context^.ExecutionState.Running := false;
     end;
end;

end.
