unit wasm.vm.opcode.i64rotr;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64RotrOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64RotrOp(Context : PWASMProcessContext);
var a, b, k : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     k := b and 63;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64((a shr k) or (a shl (64 - k))));
end;

end.
