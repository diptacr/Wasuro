unit wasm.vm.opcode.i32rotr;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32RotrOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32RotrOp(Context : PWASMProcessContext);
var a : TWASMUInt32; b : TWASMUInt32; k : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     k := b and 31;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32((a shr k) or (a shl (32 - k))));
end;

end.
