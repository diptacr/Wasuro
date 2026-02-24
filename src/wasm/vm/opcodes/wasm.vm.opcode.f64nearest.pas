unit wasm.vm.opcode.f64nearest;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64NearestOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64NearestOp(Context : PWASMProcessContext);
var a, half, r : TWASMDouble;
    t    : TWASMInt64;
    bits : TWASMUInt64;
    nan_bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     if (bits and $7FF0000000000000) = $7FF0000000000000 then
     begin
          if (bits and $000FFFFFFFFFFFFF) <> 0 then begin
               nan_bits := $7FF8000000000000;
               wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nan_bits)^);
          end else
               wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a);
     end
     else begin
          t := Trunc(a);
          r := t;
          half := a - r;
          if (half > 0.5) then
             Inc(t)
          else if (half < -0.5) then
             Dec(t)
          else if (half = 0.5) then
          begin
               if (t and 1) <> 0 then Inc(t);
          end
          else if (half = -0.5) then
          begin
               if (t and 1) <> 0 then Dec(t);
          end;
          r := t;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, r);
     end;
end;

end.
