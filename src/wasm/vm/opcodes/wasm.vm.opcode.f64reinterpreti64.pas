unit wasm.vm.opcode.f64reinterpreti64;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64ReinterpretI64Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64ReinterpretI64Op(Context : PWASMProcessContext);
var a : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@a)^);
end;

end.
