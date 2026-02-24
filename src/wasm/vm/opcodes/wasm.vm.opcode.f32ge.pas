unit wasm.vm.opcode.f32ge;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32GeOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32GeOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
    aBits, bBits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     aBits := TWASMPUInt32(@a)^;
     bBits := TWASMPUInt32(@b)^;
     if (((aBits and $7F800000) = $7F800000) and ((aBits and $007FFFFF) <> 0)) or
        (((bBits and $7F800000) = $7F800000) and ((bBits and $007FFFFF) <> 0)) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0)
     else if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
