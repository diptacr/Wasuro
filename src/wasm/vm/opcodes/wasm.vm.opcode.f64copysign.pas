unit wasm.vm.opcode.f64copysign;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64CopysignOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64CopysignOp(Context : PWASMProcessContext);
var a, b  : TWASMDouble;
    ai, bi : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     ai := TWASMPUInt64(@a)^;
     bi := TWASMPUInt64(@b)^;
     ai := (ai and $7FFFFFFFFFFFFFFF) or (bi and $8000000000000000);
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@ai)^);
end;

end.
