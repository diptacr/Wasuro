unit wasm.vm.opcode.f64sqrt;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64SqrtOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64SqrtOp(Context : PWASMProcessContext);
var a        : TWASMDouble;
    guess    : TWASMDouble;
    i        : TWASMInt32;
    bits     : TWASMUInt64;
    nan_bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     if ((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0) then
     begin
          { NaN -> canonical NaN }
          nan_bits := $7FF8000000000000;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nan_bits)^);
     end
     else if bits = $7FF0000000000000 then
          { +Infinity -> +Infinity }
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a)
     else if a = 0.0 then
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a)
     else if a < 0.0 then
     begin
          nan_bits := $7FF8000000000000;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nan_bits)^);
     end
     else
     begin
          guess := a;
          for i := 0 to 29 do
              guess := (guess + a / guess) * 0.5;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, guess);
     end;
end;

end.
