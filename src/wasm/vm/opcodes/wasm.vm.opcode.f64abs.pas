unit wasm.vm.opcode.f64abs;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64AbsOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64AbsOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     bits := bits and $7FFFFFFFFFFFFFFF;
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@bits)^);
end;

end.
