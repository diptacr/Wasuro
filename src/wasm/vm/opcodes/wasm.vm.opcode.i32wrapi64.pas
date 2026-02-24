unit wasm.vm.opcode.i32wrapi64;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32WrapI64Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32WrapI64Op(Context : PWASMProcessContext);
var v : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(v and $FFFFFFFF));
end;

end.
