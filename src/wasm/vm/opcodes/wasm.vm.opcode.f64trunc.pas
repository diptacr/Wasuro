unit wasm.vm.opcode.f64trunc;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64TruncOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64TruncOp(Context : PWASMProcessContext);
var a, r : TWASMDouble;
    t : TWASMInt64;
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
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, r);
     end;
end;

end.
