unit wasm.vm.opcode.i64mul;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64MulOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64MulOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a * b);
end;

end.
