unit wasm.vm.opcode.f64ge;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64GeOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64GeOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
    aBits, bBits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt64(@a)^;
     bBits := TWASMPUInt64(@b)^;
     if (((aBits and $7FF0000000000000) = $7FF0000000000000) and ((aBits and $000FFFFFFFFFFFFF) <> 0)) or
        (((bBits and $7FF0000000000000) = $7FF0000000000000) and ((bBits and $000FFFFFFFFFFFFF) <> 0)) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0)
     else if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
