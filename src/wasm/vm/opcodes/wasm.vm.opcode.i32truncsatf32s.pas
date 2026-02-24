unit wasm.vm.opcode.i32truncsatf32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncSatF32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncSatF32SOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
    a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt32(@a)^;
    if ((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0)
    else if a >= 2147483648.0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 2147483647)
    else if a < -2147483648.0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -2147483648)
    else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(Trunc(a)));
end;

end.
