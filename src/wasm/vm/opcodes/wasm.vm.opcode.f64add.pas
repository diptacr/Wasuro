unit wasm.vm.opcode.f64add;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64AddOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64AddOp(Context : PWASMProcessContext);
var a, b : TWASMDouble; aBits, bBits, nanBits : TWASMUInt64;
    aIsNaN, bIsNaN, aIsInf, bIsInf : TWASMBoolean;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt64(@a)^;
     bBits := TWASMPUInt64(@b)^;
     aIsNaN := ((aBits and $7FF0000000000000) = $7FF0000000000000) and ((aBits and $000FFFFFFFFFFFFF) <> 0);
     bIsNaN := ((bBits and $7FF0000000000000) = $7FF0000000000000) and ((bBits and $000FFFFFFFFFFFFF) <> 0);
     if aIsNaN or bIsNaN then begin
        nanBits := $7FF8000000000000;
        wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
     end else begin
        aIsInf := (aBits and $7FFFFFFFFFFFFFFF) = $7FF0000000000000;
        bIsInf := (bBits and $7FFFFFFFFFFFFFFF) = $7FF0000000000000;
        if aIsInf and bIsInf and ((aBits xor bBits) and $8000000000000000 <> 0) then begin
           nanBits := $7FF8000000000000;
           wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@nanBits)^);
        end else
           wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, a + b);
     end;
end;

end.
