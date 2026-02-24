unit wasm.vm.opcode.f32reinterpreti32;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32ReinterpretI32Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32ReinterpretI32Op(Context : PWASMProcessContext);
var a : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@a)^);
end;

end.
