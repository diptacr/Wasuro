unit wasm.vm.opcode.f64neg;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64NegOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64NegOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     bits := bits xor $8000000000000000;
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@bits)^);
end;

end.
