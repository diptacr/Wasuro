unit wasm.vm.opcode.f32sqrt;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32SqrtOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32SqrtOp(Context : PWASMProcessContext);
var a, guess : TWASMFloat;
    i : TWASMInt32;
    bits : TWASMUInt32;
    nan_bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if ((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0) then
     begin
          { NaN -> canonical NaN }
          nan_bits := $7FC00000;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nan_bits)^);
     end
     else if bits = $7F800000 then
          { +Infinity -> +Infinity }
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a)
     else if a = 0.0 then
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a)
     else if a < 0.0 then
     begin
          nan_bits := $7FC00000;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nan_bits)^);
     end
     else
     begin
          guess := a;
          for i := 0 to 19 do
              guess := (guess + a / guess) * 0.5;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, guess);
     end;
end;

end.
