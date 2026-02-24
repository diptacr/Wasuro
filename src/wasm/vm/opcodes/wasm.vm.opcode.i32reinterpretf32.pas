unit wasm.vm.opcode.i32reinterpretf32;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32ReinterpretF32Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32ReinterpretF32Op(Context : PWASMProcessContext);
var a : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMPUInt32(@a)^));
end;

end.
