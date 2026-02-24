unit wasm.vm.opcode.f32mul;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32MulOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32MulOp(Context : PWASMProcessContext);
var a, b : TWASMFloat; aBits, bBits, nanBits : TWASMUInt32;
    aIsNaN, bIsNaN, aIsInf, bIsInf, aIsZero, bIsZero : TWASMBoolean;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt32(@a)^;
     bBits := TWASMPUInt32(@b)^;
     aIsNaN := ((aBits and $7F800000) = $7F800000) and ((aBits and $007FFFFF) <> 0);
     bIsNaN := ((bBits and $7F800000) = $7F800000) and ((bBits and $007FFFFF) <> 0);
     if aIsNaN or bIsNaN then begin
        nanBits := $7FC00000;
        wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
     end else begin
        aIsInf := (aBits and $7FFFFFFF) = $7F800000;
        bIsInf := (bBits and $7FFFFFFF) = $7F800000;
        aIsZero := (aBits and $7FFFFFFF) = 0;
        bIsZero := (bBits and $7FFFFFFF) = 0;
        if (aIsInf and bIsZero) or (bIsInf and aIsZero) then begin
           nanBits := $7FC00000;
           wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@nanBits)^);
        end else
           wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a * b);
     end;
end;

end.
