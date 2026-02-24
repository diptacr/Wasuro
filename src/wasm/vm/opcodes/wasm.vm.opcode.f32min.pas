unit wasm.vm.opcode.f32min;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32MinOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32MinOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
    nanBits : TWASMUInt32;
    aBits, bBits, resBits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt32(@a)^;
     bBits := TWASMPUInt32(@b)^;
     if (((aBits and $7F800000) = $7F800000) and ((aBits and $007FFFFF) <> 0)) or
        (((bBits and $7F800000) = $7F800000) and ((bBits and $007FFFFF) <> 0)) then
     begin
          nanBits := $7FC00000;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
     end
     else if (a = b) then
     begin
          { Handle signed zero: min(-0.0, +0.0) = -0.0 — OR sign bits }
          resBits := aBits or bBits;
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@resBits)^);
     end
     else if a < b then
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a)
     else
          wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, b);
end;

end.
