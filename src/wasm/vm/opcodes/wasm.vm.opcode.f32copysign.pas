unit wasm.vm.opcode.f32copysign;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32CopysignOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32CopysignOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
    ai, bi : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     ai := TWASMPUInt32(@a)^;
     bi := TWASMPUInt32(@b)^;
     ai := (ai and $7FFFFFFF) or (bi and $80000000);
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@ai)^);
end;

end.
