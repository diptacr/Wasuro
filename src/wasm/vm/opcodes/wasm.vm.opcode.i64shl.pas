unit wasm.vm.opcode.i64shl;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ShlOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64ShlOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) shl (TWASMUInt64(b) and 63)));
end;

end.
