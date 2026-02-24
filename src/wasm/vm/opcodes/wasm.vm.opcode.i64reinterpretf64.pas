unit wasm.vm.opcode.i64reinterpretf64;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ReinterpretF64Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64ReinterpretF64Op(Context : PWASMProcessContext);
var a : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMPUInt64(@a)^));
end;

end.
