unit wasm.vm.opcode.i32or;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32OrOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32OrOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a or b);
end;

end.
