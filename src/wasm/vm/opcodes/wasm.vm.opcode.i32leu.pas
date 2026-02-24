unit wasm.vm.opcode.i32leu;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32LeUOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32LeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt32(a) <= TWASMUInt32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
