unit wasm.vm.opcode.f32abs;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32AbsOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32AbsOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     bits := bits and $7FFFFFFF;
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@bits)^);
end;

end.
