unit wasm.vm.opcode.f32ceil;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32CeilOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32CeilOp(Context : PWASMProcessContext);
var a, r : TWASMFloat;
    t : TWASMInt64;
    bits : TWASMUInt32;
    nan_bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if (bits and $7F800000) = $7F800000 then
     begin
          if (bits and $007FFFFF) <> 0 then begin
               nan_bits := $7FC00000;
               wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nan_bits)^);
          end else
               wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a);
     end
     else begin
          t := Trunc(a);
          r := t;
          if a > r then begin
             t := t + 1;
             r := t;
          end;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, r);
     end;
end;

end.
