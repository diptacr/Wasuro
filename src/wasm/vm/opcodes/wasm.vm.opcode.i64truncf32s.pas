unit wasm.vm.opcode.i64truncf32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncF32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncF32SOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or
        (a >= 9223372036854775808.0) or (a < -9223372036854775808.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, Trunc(a));
end;

end.
