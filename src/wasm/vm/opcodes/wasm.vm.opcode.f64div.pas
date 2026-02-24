unit wasm.vm.opcode.f64div;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64DivOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64DivOp(Context : PWASMProcessContext);
var a, b : TWASMDouble; aBits, bBits, resultBits : TWASMUInt64;
    aIsNaN, bIsNaN, aIsInf, bIsInf, aIsZero, bIsZero : TWASMBoolean;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt64(@a)^;
     bBits := TWASMPUInt64(@b)^;
     aIsNaN := ((aBits and $7FF0000000000000) = $7FF0000000000000) and ((aBits and $000FFFFFFFFFFFFF) <> 0);
     bIsNaN := ((bBits and $7FF0000000000000) = $7FF0000000000000) and ((bBits and $000FFFFFFFFFFFFF) <> 0);
     if aIsNaN or bIsNaN then begin
        resultBits := $7FF8000000000000;
        wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@resultBits)^);
     end else begin
        aIsInf := (aBits and $7FFFFFFFFFFFFFFF) = $7FF0000000000000;
        bIsInf := (bBits and $7FFFFFFFFFFFFFFF) = $7FF0000000000000;
        aIsZero := (aBits and $7FFFFFFFFFFFFFFF) = 0;
        bIsZero := (bBits and $7FFFFFFFFFFFFFFF) = 0;
        if aIsInf and bIsInf then begin
           resultBits := $7FF8000000000000;
           wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@resultBits)^);
        end else if bIsZero then begin
           if aIsZero then begin
              resultBits := $7FF8000000000000;
              wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@resultBits)^);
           end else begin
              resultBits := ((aBits xor bBits) and $8000000000000000) or $7FF0000000000000;
              wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@resultBits)^);
           end;
        end else
           wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a / b);
     end;
end;

end.
