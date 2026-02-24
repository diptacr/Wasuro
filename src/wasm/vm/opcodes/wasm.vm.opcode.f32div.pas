unit wasm.vm.opcode.f32div;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32DivOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32DivOp(Context : PWASMProcessContext);
var a, b : TWASMFloat; aBits, bBits, resultBits : TWASMUInt32;
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
        resultBits := $7FC00000;
        wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@resultBits)^);
     end else begin
        aIsInf := (aBits and $7FFFFFFF) = $7F800000;
        bIsInf := (bBits and $7FFFFFFF) = $7F800000;
        aIsZero := (aBits and $7FFFFFFF) = 0;
        bIsZero := (bBits and $7FFFFFFF) = 0;
        if aIsInf and bIsInf then begin
           resultBits := $7FC00000;
           wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@resultBits)^);
        end else if bIsZero then begin
           if aIsZero then begin
              resultBits := $7FC00000;
              wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@resultBits)^);
           end else begin
              resultBits := ((aBits xor bBits) and $80000000) or $7F800000;
              wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@resultBits)^);
           end;
        end else
           wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, a / b);
     end;
end;

end.
