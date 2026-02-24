unit wasm.vm.opcode.f64min;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64MinOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64MinOp(Context : PWASMProcessContext);
var a, b    : TWASMDouble;
    nanBits : TWASMUInt64;
    aBits, bBits, resBits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt64(@a)^;
     bBits := TWASMPUInt64(@b)^;
     if (((aBits and $7FF0000000000000) = $7FF0000000000000) and ((aBits and $000FFFFFFFFFFFFF) <> 0)) or
        (((bBits and $7FF0000000000000) = $7FF0000000000000) and ((bBits and $000FFFFFFFFFFFFF) <> 0)) then
     begin
          nanBits := $7FF8000000000000;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
     end
     else if (a = b) then
     begin
          { Handle signed zero: min(-0.0, +0.0) = -0.0 — OR sign bits }
          resBits := aBits or bBits;
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@resBits)^);
     end
     else if a < b then
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a)
     else
          wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, b);
end;

end.
