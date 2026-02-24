unit wasm.vm.opcode.i64truncsatf32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncSatF32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncSatF32SOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
    d : TWASMDouble;
begin
    a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt32(@a)^;
    if ((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0) then
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, 0)
    else begin
        d := a;
        if d >= 9223372036854775808.0 then
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64($7FFFFFFFFFFFFFFF))
        else if d < -9223372036854775808.0 then
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64($8000000000000000))
        else
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(Trunc(d)));
    end;
end;

end.
