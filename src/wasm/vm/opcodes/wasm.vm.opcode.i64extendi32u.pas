unit wasm.vm.opcode.i64extendi32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ExtendI32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64ExtendI32UOp(Context : PWASMProcessContext);
var v : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt32(v)));
end;

end.
