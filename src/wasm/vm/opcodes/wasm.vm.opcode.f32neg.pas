unit wasm.vm.opcode.f32neg;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32NegOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32NegOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     bits := bits xor $80000000;
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@bits)^);
end;

end.
